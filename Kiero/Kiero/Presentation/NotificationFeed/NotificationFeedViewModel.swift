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
    private let sseRefreshSubject = PassthroughSubject<Void, Never>()
    
    private(set) var sections: [FeedSection] = []
    private var nextCursor: String? = nil
    private var canLoadMore: Bool { nextCursor != nil }
    private var cachedChildName: String = ""
    private var expandedKeys = Set<String>()
    
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
        
        let idTrigger = Publishers.Merge3(input.viewDidload, input.refresh, sseRefreshSubject)
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
        
        NotificationCenter.default.publisher(for: .feedItemCreated)
            .compactMap { $0.userInfo?["payload"] as? SseEventPayload }
            .sink { [weak self] payload in
                print("✅ FeedVM received SSE:", payload.eventType)
                self?.sseRefreshSubject.send(())
            }
            .store(in: &cancellables)
        
        return Output(
            sections: sectionsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            isLoadingMore: isLoadingMoreSubject.eraseToAnyPublisher()
        )
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
    
    // MARK: - Helpers
    
    private func getWeekday(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        guard let date = formatter.date(from: dateString) else { return "" }
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func splitOccurredAt(_ occurredAt: String) -> (date: String, time: String) {
        if occurredAt.contains("T") {
            let parts = occurredAt.split(separator: "T", maxSplits: 1)
            let rawDateString = parts.first.map(String.init) ?? occurredAt
            
            let weekday = getWeekday(from: rawDateString)
            
            var date = rawDateString.replacingOccurrences(of: "-", with: ".")
            if !weekday.isEmpty {
                date = "\(date).(\(weekday))"
            }
            
            let timePart = parts.count > 1 ? String(parts[1]) : ""
            let beforeDot = String(timePart.split(separator: ".", maxSplits: 1).first ?? Substring(timePart))
            
            let time = beforeDot
                .split(separator: ":", maxSplits: 2)
                .prefix(2)
                .joined(separator: ":")
            
            return (date, time)
        }
        
        let parts = occurredAt.split(separator: " ")
        if parts.count >= 2 {
            let rawDateString = String(parts[0])
            let weekday = getWeekday(from: rawDateString)
            
            var date = rawDateString
            if !weekday.isEmpty {
                date = "\(date).(\(weekday))"
            }
            
            return (date, String(parts[1]))
        }
        
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
            let key = makeDedupKey(
                eventType: item.eventType,
                occurredAt: item.occurredAt,
                metadata: item.metadata
            )
            
            return .finishSchedule(
                key: key,
                time: time,
                childName: childName,
                schedule: item.metadata.content ?? "",
                proofImageUrl: item.metadata.imageUrl,
                isExpanded: expandedKeys.contains(key)
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
        
        let before = sections[indexPath.section].items[indexPath.row]
        if case let .finishSchedule(key, _, _, _, _, isExpanded) = before{
            if isExpanded {
                expandedKeys.remove(key)
            } else {
                expandedKeys.insert(key)
            }
        }
        
        sections[indexPath.section].items[indexPath.row].toggleExpanded()
        sectionsSubject.send(sections)
    }
}
