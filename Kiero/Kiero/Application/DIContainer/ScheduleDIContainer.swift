//
//  ScheduleDIContainer.swift
//  Kiero
//
//  Created by 안치욱 on 5/1/26.
//

import UIKit

final class ScheduleDIContainer {

    private let appDIContainer: AppDIContainer

    private lazy var scheduleService: ScheduleServiceType = {
        ScheduleService()
    }()

    private lazy var addScheduleService: AddScheduleServiceType = {
        AddScheduleService()
    }()

    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

extension ScheduleDIContainer {
    
    func makeScheduleViewController() -> ScheduleViewController {
        let viewModel = ScheduleViewModel(
            service: scheduleService,
            childId: appDIContainer.userSessionStorage.selectedChildId,
            userSessionStorage: appDIContainer.userSessionStorage,
            authTokenStorage: appDIContainer.authTokenStorage
        )
        
        let timeTableVC = makeTimeTableViewController(viewModel: viewModel)
        
        return ScheduleViewController(
            viewModel: viewModel,
            scheduleChildVC: timeTableVC
        )
    }

    func makeTimeTableViewController(
        viewModel: ScheduleViewModel
    ) -> TimeTableViewController {
        TimeTableViewController(viewModel: viewModel)
    }

    func makeAddScheduleViewController() -> AddScheduleViewController {
        makeAddScheduleViewController(
            isFireLit: false,
            scheduleList: []
        )
    }

    func makeAddScheduleViewController(
        isFireLit: Bool,
        scheduleList: [Schedule]
    ) -> AddScheduleViewController {
        let viewModel = AddScheduleViewModel(
            service: addScheduleService,
            childId: appDIContainer.userSessionStorage.selectedChildId
        )

        viewModel.isFireLit = isFireLit
        viewModel.scheduleList = scheduleList

        return AddScheduleViewController(viewModel: viewModel)
    }

    func makeEditScheduleViewController(
        schedule: Schedule
    ) -> AddScheduleViewController {
        let viewController = makeAddScheduleViewController(
            isFireLit: false,
            scheduleList: []
        )

        viewController.isEditMode = true
        viewController.editingSchedule = schedule

        return viewController
    }
}
