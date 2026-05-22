//
//  MyPageHostingController.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import SwiftUI

final class MyPageHostingController: UIHostingController<MyPageView> {
    
    let viewModel: MyPageViewModel
    
    var onChildConnectionTap: (() -> Void)?
    var onLogoutConfirm: (() -> Void)?
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        
        super.init(
            rootView: MyPageView(
                viewModel: viewModel,
                onChildConnectionTap: {},
                onLogoutConfirm: {}
            )
        )
        
        self.rootView = MyPageView(
            viewModel: viewModel,
            onChildConnectionTap: { [weak self] in
                self?.onChildConnectionTap?()
            },
            onLogoutConfirm: { [weak self] in
                self?.onLogoutConfirm?()
            }
        )
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
