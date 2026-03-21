//
//  RewardHostingController.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import Combine
import SwiftUI
import UIKit

final class RewardHostingController: UIHostingController<RewardView> {
    
    private let viewModel: RewardViewModel
    
    init(viewModel: RewardViewModel) {
        self.viewModel = viewModel
        super.init(rootView: RewardView(viewModel: viewModel))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RewardHostingController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        viewModel.fetchCoupons()
    }
    
}

extension RewardHostingController: ScrollToTopAvailable {
    func scrollToTop() {
        findScrollViewAndScrollToTop(in: self.view)
    }
    
    private func findScrollViewAndScrollToTop(in view: UIView) {
        if let scrollView = view as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: -66), animated: true)
            return
        }
        
        for subview in view.subviews {
            findScrollViewAndScrollToTop(in: subview)
        }
    }
}
