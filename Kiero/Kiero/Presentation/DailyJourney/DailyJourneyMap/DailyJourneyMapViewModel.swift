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
    
    let confirmButtonTapSubject = PassthroughSubject<Void, Never>()
        
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let confirmButtonTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let dismiss: AnyPublisher<Void, Never>
    }
        
    private let dismissSubject = PassthroughSubject<Void, Never>()
        
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .sink { [weak self] in
                self?.fetchJourneyList()
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
    
    // MARK: - Network
    
    private func fetchJourneyList() {
        DailyJourneyMapService.shared.fetchJourneyList()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ DailyJourneyMap fetch 에러: \(error)")
                }
            } receiveValue: { [weak self] data in
                self?.scheduleData = data
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    
    var todayDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: Date())
    }
}
