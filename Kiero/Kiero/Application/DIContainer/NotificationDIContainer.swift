//
//  NotificationDIContainer.swift
//  Kiero
//
//  Created by 안치욱 on 5/1/26.
//

import UIKit

final class NotificationDIContainer {
    
    private let appDIContainer: AppDIContainer
    
    private lazy var feedService: FeedServiceType = {
        FeedService()
    }()
    
    private lazy var scheduleService: ScheduleServiceType = {
        ScheduleService()
    }()
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

extension NotificationDIContainer {
    func makeNotificationFeedViewModel() -> NotificationFeedViewModel {
        NotificationFeedViewModel(
            feedService: feedService,
            scheduleService: scheduleService,
            userSessionStorage: appDIContainer.userSessionStorage
        )
    }
    
    func makeNotificationFeedViewController() -> NotificationFeedViewController {
        let viewModel = makeNotificationFeedViewModel()
        
        return NotificationFeedViewController(viewModel: viewModel)
    }
}
