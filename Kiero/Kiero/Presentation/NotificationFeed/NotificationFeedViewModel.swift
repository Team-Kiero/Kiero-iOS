//
//  NotificationFeedViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//

import Combine
import UIKit

final class NotificationFeedViewModel: BaseViewModel, ViewModelType {
    
    private let feedService: FeedServiceType
    private let scheduleService: ScheduleServiceType
    private let pageSize: Int
    
    private var childId: Int {
        get { UserDefaults.standard.integer(forKey: "selectedChildId") }
        set { UserDefaults.standard.set(newValue, forKey: "selectedChildId") }
    }
    
    private let itemsSubject = CurrentValueSubject<[FeedItem], Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let sectionsSubject = CurrentValueSubject<[FeedSection], Never>([])
    let logoutSuccess = PassthroughSubject<Void, Never>()
    
    private(set) var sections: [FeedSection] = []
    private var nextCursor: String? = nil
    private var canLoadMore: Bool { nextCursor != nil }
    private var cachedChildName: String = ""
    private var seenKeys = Set<String>()
    private var sseStarted = false
    
    init(
        feedService: FeedServiceType,
        scheduleService: ScheduleServiceType,
        pageSize: Int = 20
    ) {
        self.feedService = feedService
        self.scheduleService = scheduleService
        self.pageSize = pageSize
        super.init()
    }
    
    struct Input {
        let viewDidload: AnyPublisher<Void, Never>
        let viewWillDisappear: AnyPublisher<Void, Never>
        let refresh: AnyPublisher<Void, Never>
        let loadMore: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let sections: AnyPublisher<[FeedSection], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let isLoadingMore: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input) -> Output {
        
        let idTrigger = Publishers.Merge(input.viewDidload, input.refresh)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
                self?.nextCursor = nil
            })
            .flatMap { [weak self] _ -> AnyPublisher<Int, Never> in
                guard let self = self else { return Just(0).eraseToAnyPublisher() }
                
                if self.childId != 0 {
                    return Just(self.childId).eraseToAnyPublisher()
                }
                
                return self.scheduleService.fetchChildren()
                    .map { children -> Int in
                        if let firstId = children.first?.childId {
                            self.childId = firstId
                            return firstId
                        }
                        return 0
                    }
                    .replaceError(with: 0)
                    .eraseToAnyPublisher()
            }
            .share()
        
        idTrigger
            .filter { $0 != 0 }
            .flatMap { [weak self] id -> AnyPublisher<FeedPage, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.feedService.fetchFeeds(childId: Int64(id), size: self.pageSize, cursor: nil)
                    .catch { [weak self] _ in
                        self?.isLoadingSubject.send(false)
                        return Empty<FeedPage, Never>()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] page in
                guard let self = self else { return }
                
                self.cachedChildName = page.childName
                
                self.itemsSubject.send(page.items)
                self.nextCursor = page.nextCursor
                
                let newSections = self.makeSections(items: page.items, childName: page.childName)
                self.sections = newSections
                self.sectionsSubject.send(newSections)
                
                self.isLoadingSubject.send(false)
            }
            .store(in: &cancellables)
        
        idTrigger
            .filter { $0 != 0 }
            .sink { [weak self] _ in
                guard let self else { return }
                self.startSSEIfNeeded()
            }
            .store(in: &cancellables)
        
        // 무한 스크롤 처리
        input.loadMore
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.canLoadMore && !self.isLoadingMoreSubject.value && !self.isLoadingSubject.value
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingMoreSubject.send(true)
            })
            .flatMap { [weak self] _ -> AnyPublisher<FeedPage, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.feedService.fetchFeeds(childId: Int64(self.childId), size: self.pageSize, cursor: self.nextCursor)
                    .catch { [weak self] _ in
                        self?.isLoadingMoreSubject.send(false)
                        return Empty<FeedPage, Never>()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] page in
                guard let self = self else { return }
                
                self.cachedChildName = page.childName
                
                var current = self.itemsSubject.value
                current.append(contentsOf: page.items)
                self.itemsSubject.send(current)
                
                let newSections = self.makeSections(items: current, childName: page.childName)
                self.sections = newSections
                self.sectionsSubject.send(newSections)
                
                self.nextCursor = page.nextCursor
                self.isLoadingMoreSubject.send(false)
            }
            .store(in: &cancellables)
        
        input.viewWillDisappear
            .sink (receiveValue:{ [weak self] _ in
                self?.stopSSE()
            })
            .store(in: &cancellables)
        
        return Output(
            sections: sectionsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - SSE
    
    private func startSSEIfNeeded() {
        guard !sseStarted else { return }
        sseStarted = true
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let initialToken = try await BaseService.shared.reissueSseAccessToken()
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    SseStreamManager.shared.startIfNeeded(initialToken: initialToken) { [weak self] payload in
                        self?.handleSse(payload: payload)
                    }
                    
                    print("✅ [FeedVM] SSE started")
                }
            } catch {
                print("❌ [FeedVM] SSE initial token reissue failed:", error)
                self.sseStarted = false
            }
        }
    }
    
    private func stopSSE() {
        SseStreamManager.shared.stop()
        sseStarted = false
    }
    
    private func handleSse(payload: SseEventPayload) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let eventType = self.mapServerEventType(payload.eventType)
            let occurredAt = payload.occurredAt ?? ""
            
            let metadata = FeedMetadata(
                content: payload.metadata?.content,
                imageUrl: payload.metadata?.imageUrl,
                amount: payload.metadata?.amount
            )
            
            let key = self.makeDedupKey(eventType: eventType, occurredAt: occurredAt, metadata: metadata)
            guard !self.seenKeys.contains(key) else { return }
            self.seenKeys.insert(key)
            
            let newItem = FeedItem(
                eventType: eventType,
                occurredAt: occurredAt,
                metadata: metadata
            )
            
            var current = self.itemsSubject.value
            current.insert(newItem, at: 0)
            self.itemsSubject.send(current)
            
            let newSections = self.makeSections(items: current, childName: self.cachedChildName)
            self.sections = newSections
            self.sectionsSubject.send(newSections)
        }
    }
    
    private func makeDedupKey(
        eventType: FeedEventType,
        occurredAt: String,
        metadata: FeedMetadata
    ) -> String {
        [
            eventType.rawValue,
            occurredAt,
            metadata.content ?? "",
            metadata.imageUrl ?? "",
            String(metadata.amount ?? -1)
        ].joined(separator: "|")
    }
    
    private func mapServerEventType(_ raw: String) -> FeedEventType {
        switch raw {
        case "MISSION_COMPLETED": return .mission
        case "SCHEDULE_COMPLETED": return .schedule
        case "COUPON_PURCHASED": return .coupon
        case "FIRE_LIT": return .complete
        default: return .mission
        }
    }
    
    func performLogout() {
        scheduleService.deleteChildDummyData()
            .handleEvents(receiveSubscription: { _ in
                print("📡 [1단계] 아이 데이터 삭제 API 구독 시작")
            })
            .catch { error in
                print("⚠️ [1단계 에러] 삭제 실패(무시하고 진행): \(error)")
                return Just(())
            }
            .flatMap { [weak self] _ -> AnyPublisher<Void, NetworkError> in
                print("🚀 [2단계] 부모 로그아웃 API 요청 전송")
                guard let self = self else { return Fail(error: .unknownError).eraseToAnyPublisher() }
                return self.scheduleService.logout()
            }
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ 최종 로그아웃 실패: \(error)")
                }
            } receiveValue: { [weak self] _ in
                print("✅ 서버 로그아웃 응답 성공")
                TokenManager.shared.clearAll()
                self?.logoutSuccess.send(())
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    
    private func splitOccurredAt(_ occurredAt: String) -> (date: String, time: String) {
        if occurredAt.contains("T") {
            let parts = occurredAt.split(separator: "T", maxSplits: 1)
            var date = parts.first.map(String.init) ?? occurredAt
            date = date.replacingOccurrences(of: "-", with: ".")
            
            let timePart = parts.count > 1 ? String(parts[1]) : ""
            let beforeDot = String(timePart.split(separator: ".", maxSplits: 1).first ?? Substring(timePart))
            
            let time = beforeDot
                .split(separator: ":", maxSplits: 2)
                .prefix(2)
                .joined(separator: ":")
            
            return (date, time)
        }
        
        let parts = occurredAt.split(separator: " ")
        if parts.count >= 2 { return (String(parts[0]), String(parts[1])) }
        
        return (occurredAt, "")
    }
    
    private func makeState(from item: FeedItem, childName: String) -> NotificationFeed.State {
        let (_, time) = splitOccurredAt(item.occurredAt)
        
        switch item.eventType {
        case .mission:
            return .finishMission(
                time: time,
                childName: childName,
                mission: item.metadata.content ?? "",
                coinEarned: item.metadata.amount ?? 0
            )
        case .schedule:
            return .finishSchedule(
                time: time,
                childName: childName,
                schedule: item.metadata.content ?? "",
                proofImageUrl: item.metadata.imageUrl,
                isExpanded: false
            )
        case .coupon:
            return .useCoupon(
                time: time,
                childName: childName,
                coupon: item.metadata.content ?? "",
                coinUsed: item.metadata.amount ?? 0
            )
        case .complete:
            return .finishAllSchedule(
                time: time,
                childName: childName,
                coinEarned: item.metadata.amount ?? 0
            )
        }
    }
    
    private func makeSections(items: [FeedItem], childName: String) -> [FeedSection] {
        var dict: [String: [NotificationFeed.State]] = [:]
        
        for item in items {
            let (date, _) = splitOccurredAt(item.occurredAt)
            let state = makeState(from: item, childName: childName)
            dict[date, default: []].append(state)
        }
        
        let sortedDates = dict.keys.sorted(by: >)
        return sortedDates.map { date in
            FeedSection(date: date, items: dict[date] ?? [])
        }
    }
}

extension NotificationFeedViewModel {
    func toggleExpansion(at indexPath: IndexPath) {
        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].items.indices.contains(indexPath.row) else { return }
        
        sections[indexPath.section].items[indexPath.row].toggleExpanded()
        sectionsSubject.send(sections)
    }
}
