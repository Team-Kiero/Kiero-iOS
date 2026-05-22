//
//  WishRoomHostingController.swift
//  Kiero
//
//  Created by 정윤아 on 5/23/26.
//

import SwiftUI

final class WishRoomHostingController: UIHostingController<WishRoomView> {
    
    private let viewModel: WishRoomViewModel
    
    init(viewModel: WishRoomViewModel = WishRoomViewModel()) {
        self.viewModel = viewModel
        super.init(rootView: WishRoomView(viewModel: viewModel))
        
        self.viewModel.onNavigateToWishWell = { [weak self] in
            let wishWellVC = AppDIContainer.shared.makeWishWellViewController()
            self?.navigationController?.pushViewController(wishWellVC, animated: true)
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
