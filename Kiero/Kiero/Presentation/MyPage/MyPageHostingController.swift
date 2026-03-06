//
//  MyPageHostingController.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import SwiftUI
import UIKit

final class MyPageHostingController: UIHostingController<MyPageView> {
    
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

extension MyPageHostingController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
    }
}

extension MyPageHostingController: ScrollToTopAvailable {
    func scrollToTop() {
        viewModel.scrollToTop.send()
    }
}
