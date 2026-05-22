//
//  MySpaceHostingController.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import SwiftUI
import UIKit

final class MySpaceHostingController: UIHostingController<MySpaceView> {
    
    var onWishSpaceTap: (() -> Void)?
    var onTermsTap: (() -> Void)?
    var onLogoutConfirm: (() -> Void)?
    
    init() {
        super.init(
            rootView: MySpaceView(
                onWishSpaceTap: {},
                onTermsTap: {},
                onLogoutConfirm: {}
            )
        )
        
        self.rootView = MySpaceView(
            onWishSpaceTap: { [weak self] in
                self?.onWishSpaceTap?()
            },
            onTermsTap: { [weak self] in
                self?.onTermsTap?()
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
