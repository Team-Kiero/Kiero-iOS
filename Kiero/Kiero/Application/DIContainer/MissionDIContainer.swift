//
//  MissionDIContainer.swift
//  Kiero
//
//  Created by 안치욱 on 5/1/26.
//

import UIKit

final class MissionDIContainer {
    
    private let appDIContainer: AppDIContainer
    
    private lazy var missionService: MissionServiceType = {
        MissionService()
    }()
    
    private lazy var aiMissionService: AIMissionServiceType = {
        AIMissionService()
    }()
    
    private lazy var writeMissionService: WriteMissionServiceType = {
        WriteMissionService()
    }()
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

extension MissionDIContainer {
    func makeMissionViewController() -> MissionViewController {
        let viewModel = MissionViewModel(
            service: missionService,
            userSessionStorage: appDIContainer.userSessionStorage
        )
        
        return MissionViewController(viewModel: viewModel)
    }
    
    func makeWriteMissionViewController() -> WriteMissionViewController {
        let viewModel = WriteMissionViewModel(
            service: writeMissionService,
            childId: appDIContainer.userSessionStorage.selectedChildId,
            userSessionStorage: appDIContainer.userSessionStorage
        )

        return WriteMissionViewController(viewModel: viewModel)
    }
    
    func makeLoadingViewController() -> LoadingViewController {
        let viewModel = LoadingViewModel()
        
        return LoadingViewController(viewModel: viewModel)
    }
    
    func makeAIMissionViewController() -> AIMissionViewController {
        let viewModel = AIMissionViewModel(
            service: aiMissionService,
            userSessionStorage: appDIContainer.userSessionStorage
        )
        
        return AIMissionViewController(viewModel: viewModel)
    }
}
