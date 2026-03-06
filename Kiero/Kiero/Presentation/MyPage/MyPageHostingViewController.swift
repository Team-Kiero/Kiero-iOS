//
//  MyPageHostingViewController.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import SwiftUI
import UIKit

final class MyPageHostingViewController: UIHostingController<MyPageView> {
    
    // MARK: - Properties
    
    private let viewModel: MyPageViewModel
    
    // MARK: - Init
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(rootView: MyPageView(viewModel: viewModel))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - TabBarReselectRefreshable

extension MyPageHostingViewController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
    }
}

extension MyPageHostingViewController: ScrollToTopAvailable {
    func scrollToTop() {
        viewModel.scrollToTop.send()
    }
}
