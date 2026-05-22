//
//  TodayStatusCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import SwiftUI
import UIKit

final class TodayStatusCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    
    init(
        navigationController: UINavigationController,
        factory: ViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() -> UIViewController {
        let vc = factory.makeTodayStatusViewController()
        
        vc.onMissionSheetRequested = { [weak self, weak vc] selectedTab in
            guard let self, let vc else { return }
            self.showMissionBottomSheet(from: vc, selectedTab: selectedTab)
        }
        
        vc.onScheduleOverlayRequested = { [weak self, weak vc] schedule in
            guard let self, let vc else { return }
            self.showScheduleImageOverlay(from: vc, schedule: schedule)
        }
        
        return vc
    }
    
    private func showMissionBottomSheet(
        from viewController: TodayStatusHostingController,
        selectedTab: MissionTab
    ) {
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .dimNavigationBar, object: true)
        
        let sheetView = MissionBottomSheetContainerView(
            selectedTab: selectedTab,
            completeMissions: viewController.viewModel.completeMissions,
            incompleteMissions: viewController.viewModel.incompleteMissions
        )
        
        let vc = UIHostingController(rootView: sheetView)
        vc.view.backgroundColor = .clear
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        viewController.present(vc, animated: false)
    }
    
    private func showScheduleImageOverlay(
        from viewController: TodayStatusHostingController,
        schedule: ScheduleItem
    ) {
        NotificationCenter.default.post(name: .dimNavigationBar, object: true)
        
        let overlayView = ScheduleImageOverlayContainerView(
            schedule: schedule,
            viewModel: viewController.viewModel
        )
        
        let vc = UIHostingController(rootView: overlayView)
        vc.view.backgroundColor = .clear
        vc.modalPresentationStyle = .overFullScreen
        
        viewController.present(vc, animated: false)
    }
}
