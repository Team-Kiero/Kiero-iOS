//
//  DailyJourneyMapViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 3/4/26.
//

import Combine
import UIKit

final class DailyJourneyMapViewModel: BaseViewModel, ViewModelType, ObservableObject {
    
    @Published var scheduleData: DailyJourneyMapData?
    @Published var isFireLit: Bool = false
    @Published var todayDateText: String = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: Date())
    }()
    
    let confirmButtonTapSubject = PassthroughSubject<Void, Never>()
    
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let confirmButtonTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let dismiss: AnyPublisher<Void, Never>
    }
    
    private let dismissSubject = PassthroughSubject<Void, Never>()
    private var shouldUpdateDateOnNextFetch = false
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .sink { [weak self] in
                self?.fetchJourneyList()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.startSseConnection()
                }
            }
            .store(in: &cancellables)
        
        input.confirmButtonTap
            .sink { [weak self] in
                self?.dismissSubject.send()
            }
            .store(in: &cancellables)
        
        return Output(
            dismiss: dismissSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - SSE
    
    private func startSseConnection() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSseEvent(_:)),
            name: .sseEventReceived,
            object: nil
        )
        
        Task {
            do {
                let token = try await TokenRefresher.shared.reissueSseAccessToken()
                await MainActor.run {
                    SseStreamManager.shared.startIfNeeded(initialToken: token) { _ in }
                }
            } catch {
                print("❌ [DailyJourneyMapVM] SSE 토큰 발급 실패: \(error)")
            }
        }
    }
    
    @objc private func handleSseEvent(_ notification: Notification) {
        guard let payload = notification.userInfo?["payload"] as? SseEventPayload else { return }
        guard payload.eventType == "SCHEDULE_STATUS_UPDATED"
                || payload.eventType == "SCHEDULE_MODIFIED"
                || payload.eventType == "DATE_CHANGED" else { return }
        print("📩 [DailyJourneyMapVM] SSE Event: \(payload.eventType)")
        if payload.eventType == "DATE_CHANGED" {
            shouldUpdateDateOnNextFetch = true
        }
        fetchJourneyList()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Network
    
    private func fetchJourneyList() {
        Publishers.Zip(
            DailyJourneyMapService.shared.fetchJourneyList(),
            DailyJourneyService.shared.updateDailyJourney()
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                print("❌ DailyJourneyMap fetch 에러: \(error)")
            }
        } receiveValue: { [weak self] (mapData, journeyDTO) in
            guard let self else { return }
            if self.shouldUpdateDateOnNextFetch {
                self.shouldUpdateDateOnNextFetch = false
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "M월 d일 EEEE"
                self.todayDateText = formatter.string(from: Date())
            }
            self.scheduleData = mapData
            self.isFireLit = journeyDTO.scheduleStatus == .fireLit
        }
        .store(in: &cancellables)
    }
    
}
