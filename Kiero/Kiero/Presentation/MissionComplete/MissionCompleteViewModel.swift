//
//  MissionCompleteViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import UIKit
import Combine

struct MissionCompleteViewData {
    let capturedImage: UIImage?
    let stoneImage: UIImage
    let message: String
    let highlightKeyword: String
}

final class MissionCompleteViewModel: BaseViewModel, ViewModelType {
    
    var capturedImage: UIImage?
    var scheduleDetailId: Int = 2
    
    // MARK: - Input & Output
    
    struct Input {
        let viewDidAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let missionData: AnyPublisher<MissionCompleteViewData, Never>
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let missionDataPublisher = input.viewDidAppear
            .map { [weak self] _ -> MissionCompleteViewData in
                guard let self = self else {
                    return MissionCompleteViewData(capturedImage: nil, stoneImage: UIImage(), message: "", highlightKeyword: "")
                }
                
                let completeModel = MissioinCompleteModel.from(scheduleDetailId: self.scheduleDetailId)
                
                return MissionCompleteViewData(
                    capturedImage: self.capturedImage,
                    stoneImage: completeModel.image,
                    message: completeModel.message,
                    highlightKeyword: completeModel.highlightKeyword
                )
            }
            .eraseToAnyPublisher()
        
        return Output(missionData: missionDataPublisher)
    }
}
