//
//  RewardHostingViewController.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import Combine
import SwiftUI
import UIKit

final class RewardHostingController: UIHostingController<RewardView>, ScrollToTopAvailable, TabBarReselectRefreshable {
    
    private let viewModel: RewardViewModel
    
    init(viewModel: RewardViewModel) {
        self.viewModel = viewModel
        super.init(rootView: RewardView(viewModel: viewModel))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshOnTabReselect() {
        viewModel.fetchRewards()
    }
    
    func scrollToTop() {
        viewModel.scrollToTop.send()
    }
}
