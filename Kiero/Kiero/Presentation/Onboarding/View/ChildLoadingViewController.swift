//
//  ChildrenLoadingViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import Lottie
import SnapKit
import Then

final class ChildLoadingViewController: BaseViewController<BaseViewModel> {
    
    // MARK: - UI Components
    
    private let skeletonView = LottieAnimationView(name: "kieroSkeleton").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
        $0.animationSpeed = 1.0
    }
    
    override func setStyle() {
        skeletonView.play()
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
