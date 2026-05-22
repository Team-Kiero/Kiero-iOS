//
//  MySpaceHostingController.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import SwiftUI

final class MySpaceHostingController: UIHostingController<MySpaceView> {
    
    init() {
        super.init(rootView: MySpaceView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MySpaceHostingController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {}
}

extension MySpaceHostingController: ScrollToTopAvailable {
    func scrollToTop() {}
}
