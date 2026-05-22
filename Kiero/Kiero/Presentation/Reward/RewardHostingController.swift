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
    
    let viewModel: RewardViewModel
    
    var onAddRewardTap: (() -> Void)?
    var onEditRewardTap: ((Reward) -> Void)?
    
    init(viewModel: RewardViewModel) {
        self.viewModel = viewModel
        
        super.init(
            rootView: RewardView(
                viewModel: viewModel,
                onAddRewardTap: {},
                onEditRewardTap: { _ in }
            )
        )
        
        self.rootView = RewardView(
            viewModel: viewModel,
            onAddRewardTap: { [weak self] in
                self?.onAddRewardTap?()
            },
            onEditRewardTap: { [weak self] reward in
                self?.onEditRewardTap?(reward)
            }
        )
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
        findScrollViewAndScrollToTop(in: view)
    }
    
    private func findScrollViewAndScrollToTop(in view: UIView) {
        if let scrollView = view as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: -61), animated: true)
            return
        }
        
        for subview in view.subviews {
            findScrollViewAndScrollToTop(in: subview)
        }
    }
}
