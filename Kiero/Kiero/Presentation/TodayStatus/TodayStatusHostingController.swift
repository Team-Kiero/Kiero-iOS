//
//  TodayStatusHostingController.swift
//  Kiero
//
//  Created by 신혜연 edited by 안치욱 on 3/2/26.
//

import SwiftUI
import UIKit

final class TodayStatusHostingController: UIHostingController<TodayStatusView> {
    
    let viewModel: TodayStatusViewModel
    
    var onMissionSheetRequested: ((MissionTab) -> Void)?
    var onScheduleOverlayRequested: ((ScheduleItem) -> Void)?
    
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
                self?.onMissionSheetRequested?(selectedTab)
            },
            onScheduleOverlayRequested: { [weak self] schedule in
                self?.onScheduleOverlayRequested?(schedule)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.unbindSSE()
    }
}

extension TodayStatusHostingController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        viewModel.fetchTodayStatus()
    }
}
