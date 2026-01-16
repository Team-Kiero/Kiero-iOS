//
//  ChildLoadingViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ChildLoadingViewController: BaseViewController<BaseViewModel> {
    
    // MARK: - UI Components
    
    private let skeletonView = UIImageView()
    
    override func setStyle() {
        skeletonView.kf.setImage(with: Bundle.main.url(forResource: "kieroSkeleton", withExtension: "gif"))
    }
    
    override func setUI() {
        view.addSubviews(skeletonView)
    }
    
    override func setLayout() {
        skeletonView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(298)
            $0.width.equalTo(130)
            $0.height.equalTo(100)
        }
    }
}

#Preview {
    ChildLoadingViewController(viewModel: BaseViewModel(), diContainer: AppDIContainer.shared)
}
