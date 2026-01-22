//
//  DialogBox.swift
//  Kiero
//
//  Created by 정윤아 on 1/9/26.
//

import UIKit

import SnapKit
import Then

final class DialogBox: UIView {
    
    // MARK: - State
    
    enum State {
        case missionComplete(title: String)
        case logout
        case wishWell(title: String, coin: String)
        case nextJourney
        
        var title: String {
            switch self {
            case .missionComplete(let title):
                return "["+title+"]"
            case .logout:
                return "로그아웃"
            case .wishWell(let title, _):
                return title
            case .nextJourney:
                return "다음 여정으로 갈거야?"
            }
        }
        
        var message: String {
            switch self {
            case .missionComplete:
                return "미션을 완료했다면\n아래 버튼을 눌러줘!"
            case .logout:
                return "로그아웃 하시겠습니까?"
            case .wishWell:
                return "금화를 사용해 소원을 빌까?"
            case .nextJourney:
                return "한번 다음 여정으로 넘어가면\n다시 지금 여정으로 돌아올 수 없어!"
            }
        }
        
        var coinText: String? {
            switch self {
            case .wishWell(_, let coin):
                return "\(coin)개"
            default:
                return nil
            }
        }
        
        var isCloseButtonHidden: Bool {
            switch self {
            case .logout:
                return true
            default:
                return false
            }
        }
        
        var cancelButtonTitle: String { "취소" }
        var confirmButtonTitle: String { "확인" }
    }
    
    // MARK: - Properties
    
    var onTapClose: (() -> Void)?
    var onTapCancel: (() -> Void)?
    var onTapConfirm: (() -> Void)?
    
    // MARK: - UI Conponents
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(resource: .icClose), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    private let coinStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
        $0.isHidden = true
    }
    
    private let coinIcon = UIImageView().then {
        $0.image = UIImage(resource: .ic3DCoin)
        $0.contentMode = .scaleAspectFit
    }
    
    private let coinLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .main
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    
    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .gray800
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitleColor(.kBlack, for: .normal)
        $0.backgroundColor = .main
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 24
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setStyle()
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Method
    
    private func setUI() {
        addSubviews(container, closeButton)
        
        coinStack.addArrangedSubviews(coinIcon, coinLabel)
        contentStack.addArrangedSubviews(titleLabel, coinStack, messageLabel)
        buttonStack.addArrangedSubviews(cancelButton, confirmButton)
        container.addArrangedSubviews(contentStack, buttonStack)
        
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 44, left: 16, bottom: 16, right: 16)
    }
    
    private func setStyle() {
        backgroundColor = .gray900
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    private func setLayout() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        
        coinIcon.snp.makeConstraints {
            $0.size.equalTo(18)
        }
        
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(49)
        }
        
        confirmButton.snp.makeConstraints {
            $0.height.equalTo(49)
        }
        
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        messageLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    // MARK: - Bind
    
    private func bind() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(state: State) {
        titleLabel.setTypo(.title2_20_SB, text: state.title)
        messageLabel.setTypo(.body3_14_R, text: state.message)
        messageLabel.textAlignment = .center
        coinLabel.setTypo(.title4_14_SB, text: state.coinText)
        
        cancelButton.setTypo(.title3_16_SB, text: state.cancelButtonTitle, for: .normal)
        confirmButton.setTypo(.title3_16_SB, text: state.confirmButtonTitle, for: .normal)
        closeButton.isHidden = state.isCloseButtonHidden
        
        if let coin = state.coinText {
            coinStack.isHidden = false
            coinLabel.text = coin
            
            contentStack.setCustomSpacing(4, after: titleLabel)
            contentStack.setCustomSpacing(15, after: coinStack)
        } else {
            coinStack.isHidden = true
            coinLabel.text = nil
            
            contentStack.setCustomSpacing(15, after: titleLabel)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapClose() { onTapClose?() }
    @objc
    private func didTapCancel() { onTapCancel?() }
    @objc
    private func didTapConfirm() { onTapConfirm?() }
}
