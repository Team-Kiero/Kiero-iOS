//
//  TodayStatusHostingController.swift
//  Kiero
//
//  Created by 신혜연 edited by 안치욱 on 3/2/26.
//

import SwiftUI
import UIKit

final class TodayStatusHostingController: UIHostingController<TodayStatusView> {
    
    private let todayStatusViewModel: TodayStatusViewModel
    
    init(viewModel: TodayStatusViewModel) {
        self.todayStatusViewModel = viewModel
        super.init(rootView: TodayStatusView(viewModel: viewModel))
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
        view.backgroundColor = .kBlack
        todayStatusViewModel.fetchTodayStatus()
        todayStatusViewModel.bindSSEIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        todayStatusViewModel.unbindSSE()
    }
}
