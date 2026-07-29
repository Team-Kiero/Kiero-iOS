//
//  TodayStatusHostingController.swift
//  Kiero
//
//  Created by 신혜연 edited by 안치욱 on 3/2/26.
//

import SwiftUI
import UIKit
import UserNotifications

final class TodayStatusHostingController: UIHostingController<TodayStatusView> {
    
    private let viewModel: TodayStatusViewModel
    private var hasCheckedNotification = false
    
    init(viewModel: TodayStatusViewModel) {
        self.viewModel = viewModel
        
        super.init(
            rootView: TodayStatusView(
                viewModel: viewModel,
                onMissionSheetRequested: { _ in },
                onScheduleOverlayRequested: { _ in }
            )
        )
        
        self.rootView = TodayStatusView(
            viewModel: viewModel,
            onMissionSheetRequested: { [weak self] selectedTab in
                self?.presentMissionBottomSheet(selectedTab: selectedTab)
            },
            onScheduleOverlayRequested: { [weak self] schedule in
                self?.presentScheduleImageOverlay(for: schedule)
            }
        )
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kBlack
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTodayStatus()
        viewModel.bindSSEIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNotificationPermissionIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.unbindSSE()
    }
}

private extension TodayStatusHostingController {
    func presentMissionBottomSheet(selectedTab: MissionTab) {
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .dimNavigationBar, object: true)
        
        let sheetView = MissionBottomSheetContainerView(
            selectedTab: selectedTab,
            completeMissions: viewModel.completeMissions,
            incompleteMissions: viewModel.incompleteMissions
        )
        
        let vc = UIHostingController(rootView: sheetView)
        vc.view.backgroundColor = .clear
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        present(vc, animated: false)
    }
    
    func presentScheduleImageOverlay(for schedule: ScheduleItem) {
        NotificationCenter.default.post(name: .dimNavigationBar, object: true)
        
        let overlayView = ScheduleImageOverlayContainerView(
            schedule: schedule,
            viewModel: viewModel
        )
        
        let vc = UIHostingController(rootView: overlayView)
        vc.view.backgroundColor = .clear
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: false)
    }
    
    func checkNotificationPermissionIfNeeded() {
        guard !hasCheckedNotification else { return }
        hasCheckedNotification = true
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            
            DispatchQueue.main.async {
                self?.showNotificationRequestDialog()
            }
        }
    }
    
    func showNotificationRequestDialog() {
        let dialogBox = DialogBox()
        dialogBox.configure(state: .parentRequestNotification)
        
        dialogBox.onTapConfirm = {
            dialogBox.dismiss()
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { [weak self] granted, _ in
                AmplitudeManager.shared.track(.pushPermissionResult, properties: [
                    AnalyticsEventProperty.granted: granted,
                    AnalyticsEventProperty.source: "today_status"
                ])
                guard granted else { return }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.viewModel.updateNotificationSettings(enabled: true)
                }
            }
        }
        
        dialogBox.onTapCancel = {
            dialogBox.dismiss()
        }
        
        dialogBox.onTapClose = {
            dialogBox.dismiss()
        }
        
        dialogBox.show(in: self)
    }
}

extension TodayStatusHostingController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        viewModel.fetchTodayStatus()
    }
}
