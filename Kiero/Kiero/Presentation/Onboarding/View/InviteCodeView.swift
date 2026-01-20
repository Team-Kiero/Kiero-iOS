//
//  InviteCodeView.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class InviteCodeView: UIView {
    
    // MARK: - Properties
    
    var copyButtonTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let inviteView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray800
    }
    
    private let codeLabel = UILabel().then {
        $0.textColor = .kBlack
    }
    
    private let copyButton = CTAButton(style: .black).then {
        $0.configure(title: "복사하기", icon: .icCopy)
    }
    
    private let timeLimitLabel = UILabel().then {
        $0.textColor = .schedule1
    }
    
    private let noticeLabel = UILabel().then {
        $0.textColor = .gray200
        $0.numberOfLines = 0
    }
    
    // MARK: - Life Cycle
    
    init() {
        super.init(frame: .zero)
        
        setStyle()
        setUI()
        setLayout()
        addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting Methods
    
    private func setStyle() {
        backgroundColor = .gray900
        titleLabel.setTypo(.body4_12_R, text: "우리 아이 초대 코드")
        codeLabel.setTypo(.head1_22_B, text: "별빛기사단918")
        inviteView.backgroundColor = .white
        timeLimitLabel.setTypo(.body4_12_R, text: "유효기간 09:23")
        noticeLabel.setTypo(.body4_12_R, text: "이 코드를 아이에게 알려주시고,\n회원가입 시 입력하도록 안내해주세요.")
        noticeLabel.textAlignment = .center
    }
    
    private func setUI() {
        layer.cornerRadius = 15
        
        addSubviews(
            inviteView,
            copyButton,
            timeLimitLabel,
            noticeLabel
        )
        
        inviteView.addSubviews(
            titleLabel,
            codeLabel
        )
    }
    
    private func setLayout() {
        inviteView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(27)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(49.5)
            $0.height.equalTo(62)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
        
        codeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(49.5)
            $0.top.equalTo(inviteView.snp.bottom).offset(11)
            $0.height.equalTo(45)
        }
        
        timeLimitLabel.snp.makeConstraints {
            $0.top.equalTo(copyButton.snp.bottom).offset(19)
            $0.centerX.equalToSuperview()
        }
        
        noticeLabel.snp.makeConstraints {
            $0.top.equalTo(timeLimitLabel.snp.bottom).offset(9)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func addTarget() {
        copyButton.addTarget(self, action: #selector(copyButtonDidTap), for: .touchUpInside)
    }
    
    @objc
    private func copyButtonDidTap() {
        UIPasteboard.general.string = codeLabel.text
        Toast.show(message: "초대코드가 복사되었습니다.", bottomInset: 141)
    }
}
