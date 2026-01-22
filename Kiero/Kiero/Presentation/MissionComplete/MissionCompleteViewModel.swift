//
//  MissionCompleteViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import Combine
import UIKit

struct MissionCompleteViewData {
    let capturedImage: UIImage?
    let stoneImage: UIImage
    let message: String
    let highlightKeyword: String
}

final class MissionCompleteViewModel: BaseViewModel, ViewModelType {
    
    var capturedImage: UIImage?
    var receivedStoneType: StoneType?
    var scheduleDetailId: Int?
    
    // MARK: - Input & Output
    
    struct Input {
        let viewDidAppear: AnyPublisher<Void, Never>
        let completeButtonTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let missionData: AnyPublisher<MissionCompleteViewData, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let event: AnyPublisher<Event, Never>
    }
    
    enum Event {
        case success
        case failure(String)
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let eventSubject = PassthroughSubject<Event, Never>()
        let loadingSubject = PassthroughSubject<Bool, Never>()
        
        let viewDataPublisher = input.viewDidAppear
            .map { [weak self] _ -> MissionCompleteViewData in
                guard let self = self else {
                    return MissionCompleteViewData(capturedImage: nil, stoneImage: UIImage(), message: "", highlightKeyword: "")
                }
                
                let stoneType = self.receivedStoneType ?? .courage
                let completeModel = MissionCompleteModel.from(stoneType: stoneType)
                
                return MissionCompleteViewData(
                    capturedImage: self.capturedImage,
                    stoneImage: completeModel.image,
                    message: completeModel.message,
                    highlightKeyword: completeModel.highlightKeyword
                )
            }
            .eraseToAnyPublisher()
        
        input.completeButtonTap
            .handleEvents(receiveOutput: { _ in
                loadingSubject.send(true)
            })
            .flatMap { [weak self] _ -> AnyPublisher<Event, Never> in
                guard let self = self,
                      let id = self.scheduleDetailId,
                      let image = self.capturedImage else {
                    return Just(.failure("필수 데이터(ID 또는 이미지)가 없습니다.")).eraseToAnyPublisher()
                }
                
                return DailyJourneyService.shared.verifyJourney(scheduleDetailId: id, image: image)
                    .map { _ in .success }
                    .catch { error in
                        Just(.failure(error.localizedDescription))
                    }
                    .eraseToAnyPublisher()
            }
            .sink { event in
                loadingSubject.send(false)
                eventSubject.send(event)
            }
            .store(in: &cancellables)
        
        return Output(
            missionData: viewDataPublisher,
            isLoading: loadingSubject.eraseToAnyPublisher(),
            event: eventSubject.eraseToAnyPublisher()
        )
    }
}
