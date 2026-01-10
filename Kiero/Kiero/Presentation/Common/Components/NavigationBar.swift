//
//  NavigationBar.swift
//  Kiero
//
//  Created by 신혜연 on 1/10/26.
//

import UIKit

import SnapKit
import Then

enum NavigationBarType {
    case back(title: String)         // <
    case closeDone(title: String)    // x v
    case close(title: String)        // x
}

final class NavigationBar: UIView {
    
    // MARK: - Properties
    
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .head2_20_B
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    let leftButton = UIButton().then {
        $0.tintColor = .white
    }
    
    let rightButton = UIButton().then {
        $0.tintColor = .white
    }
    
    // MARK: - Life Cycle
    
    init(type: NavigationBarType) {
        super.init(frame: .zero)
        
        setStyle()
        setUI()
        setLayout()
        configure(with: type)
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        self.backgroundColor = .kBlack
    }
    
    private func setUI() {
        addSubviews(leftButton, titleLabel, rightButton)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(37)
        }
        
        leftButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
    
    private func configure(with type: NavigationBarType) {
        switch type {
        case .back(let title):
            titleLabel.text = title
            leftButton.setImage(UIImage(resource: .icLeft), for: .normal)
            rightButton.isHidden = true
            
        case .closeDone(let title):
            titleLabel.text = title
            leftButton.setImage(UIImage(resource: .icClose), for: .normal)
            rightButton.setImage(UIImage(resource: .icDone), for: .normal)
            rightButton.isHidden = false
            
        case .close(let title):
            titleLabel.text = title
            leftButton.setImage(UIImage(resource: .icClose), for: .normal)
            rightButton.isHidden = true
        }
    }
    
    private func setupActions() {
        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)
    }
    
    @objc
    private func didTapLeft() { leftButtonAction?() }
    
    @objc
    private func didTapRight() { rightButtonAction?() }
}
