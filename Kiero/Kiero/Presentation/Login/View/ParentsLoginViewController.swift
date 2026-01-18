//
//  ParentsLoginViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class ParentsLoginViewController: BaseViewController<BaseViewModel> {
    
    // MARK: - UI Components
    
    private let parentNaviBar = NavigationBar(type: .back(title: "부모님으로 시작하기"))
    
    private let parentBubble = SpeechBubble(speech: "반가워요!")
    
    private let parentImageView = UIImageView().then {
        $0.image = .imgGoblinParent.resized(to: CGSize(width: 572, height: 572))
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        
    }
    
    private let kakaoLoginButton = UIButton().then {
        $0.setImage(.kakaoButton, for: .normal)
    }
    
    override func setStyle() {
        parentImageView.transform = CGAffineTransform(rotationAngle: -(.pi / 180 * 35))
    }
    
    override func setUI() {
        view.addSubviews(
            parentNaviBar,
            parentBubble,
            parentImageView,
            kakaoLoginButton
        )
    }
    
    override func setLayout() {
        parentNaviBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        
        parentBubble.snp.makeConstraints {
            $0.top.equalTo(parentNaviBar.snp.bottom).offset(131)
            $0.trailing.equalTo(parentImageView.snp.trailing).inset(378)
        }
        
        parentImageView.snp.makeConstraints {
            $0.top.equalTo(parentNaviBar.snp.bottom).offset(3)
            $0.trailing.equalToSuperview().offset(190)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-39)
            $0.height.equalTo(48)
        }
    }
}
