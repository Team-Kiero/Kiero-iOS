//
//  ConfirmBox.swift
//  Kiero
//
//  Created by 정윤아 on 1/10/26.
//

import UIKit

import SnapKit
import Then

final class ConfirmBox: UIView {
    
    // MARK: - State
    
    enum State {
        case coinMission(count: Int)
        
        case wishWell(wish: String)
        
        var message: String {
            switch self {
            case .coinMission(let count):
                return "금나와라 뚝딱!\n금화 \(count)개를 만들었어!"
            case .wishWell(let wish):
                return wish + "를\n획득했어요!"
            }
        }
        
        var buttonTitle: String {
            switch self {
            case . coinMission:
                return "받기"
            case .wishWell:
                return "확인"
            }
        }
    }
    
    // MARK: - Properties
    
    var onTapButton: (() -> Void)?
    
    // MARK: - UI Component
    
    private let characterImage = UIImageView().then {
        $0.image = UIImage(named: "img_goblin_smile")
        $0.contentMode = .scaleAspectFit
    }
    
    private let messageLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .gray100
        $0.setTypo(.body3_14_R)
    }
    
    private let actionButton = UIButton().then {
        $0.titleLabel?.font = .title3_16_SB
        $0.setTitleColor(.kBlack, for: .normal)
        $0.backgroundColor = .main
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let titleStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 3
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 24
        
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 44, left: 16, bottom: 16, right: 16)
    }
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup Methods
    
    private func setStyle() {
        backgroundColor = .gray900
        layer.cornerRadius = 16
    }
    
    private func setUI() {
        addSubviews(container)
        titleStack.addArrangedSubviews(characterImage, messageLabel)
        container.addArrangedSubviews(titleStack, actionButton)
    }
    
    private func setLayout() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(248)
        }
        
        characterImage.snp.makeConstraints {
            $0.width.equalTo(63)
            $0.height.equalTo(71)
        }
        
        actionButton.snp.makeConstraints {
            $0.width.equalTo(311)
            $0.height.equalTo(49)
        }
    }
    
    // MARK: Configure
    
    func configure(state: State) {
        messageLabel.text = state.message
        actionButton.setTitle(state.buttonTitle, for: .normal)
    }
    
    // MARK: Bind
    
    private func bind() {
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    // MARK: Action
    
    @objc
    private func didTapButton() {
        onTapButton?()
    }
    
}
