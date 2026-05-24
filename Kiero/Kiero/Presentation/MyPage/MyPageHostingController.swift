//
//  MyPageHostingController.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import SwiftUI

final class MyPageHostingController: UIHostingController<MyPageView> {
    
    private let viewModel: MyPageViewModel
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(rootView: MyPageView(viewModel: viewModel, onChildManageTap: nil, onWithdrawTap: nil))
        
        self.rootView = MyPageView(
            viewModel: viewModel,
            onChildManageTap: { [weak self] in
                let vc = UIHostingController(rootView: ChildManageView())
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            onWithdrawTap: { [weak self] in
                let vc = UIHostingController(rootView: WithdrawView())
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
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
