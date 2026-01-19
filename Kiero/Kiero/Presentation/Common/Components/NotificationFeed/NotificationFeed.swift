//
//  NotificationFeed.swift
//  Kiero
//
//  Created by 정윤아 on 1/15/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class NotificationFeed: UIView {
    
    // MARK: - State
    
    enum State {
        case finishSchedule(
            time: String,
            childName: String,
            schedule: String,
            proofImage: UIImage?,
            isExpanded: Bool
        )
        case finishAllSchedule(
            time: String,
            childName: String,
            coinEarned: Int,
        )
        case useCoupon(
            time: String,
            childName: String,
            coupon: String,
            coinUsed: Int
        )
        case finishMission(
            time: String,
            childName: String,
            mission: String,
            coinEarned: Int
        )
    }
    
    // MARK: - Properties
    
    var onToggleExpand: (() -> Void)?
    
    // MARK: - UI Component
    
    private let timeLabel = UILabel().then {
        $0.textColor = .gray400
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let downButton = UIButton().then {
        $0.tintColor = .white
        $0.setImage(UIImage(resource: .icDown), for: .normal)
        $0.isHidden = true
    }
    
    private let proofImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    private let coinChip = ChipItem().then {
        $0.isHidden = true
    }
    
    private let container = UIView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let bottomSpacer = UIView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        setAction()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        addSubview(container)
        container.addSubviews(
            timeLabel,
            messageLabel,
            downButton,
            proofImageView,
            coinChip,
            bottomSpacer
        )
    }
    
    private func setLayout() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(13)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalTo(downButton.snp.leading).offset(0)
        }
        
        downButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().inset(13)
            $0.centerY.equalTo(messageLabel)
        }
        
        coinChip.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(13)
//            $0.bottom.equalToSuperview().inset(12)
        }
        
        proofImageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        bottomSpacer.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview().inset(14)
        }
    }
    
    private func setAction() {
        downButton.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
    }
    
    // MARK: - Congifuration
    
    func configure(_ state: State) {
        downButton.isHidden = true
        proofImageView.isHidden = true
        coinChip.isHidden = true
        proofImageView.snp.updateConstraints{ $0.height.equalTo(0) }
        
        let style: UIFont.NotoSans = .title3_16_SB
        
        switch state {
        case let .finishSchedule(time, childName, schedule, proofImage, isExpanded):
            timeLabel.setTypo(.body4_12_R, text: time)
            downButton.isHidden = false
            let subject = "\(childName)\(childName.subjectMarker)"
            let base = "\(subject) \(schedule)에 도착했어요."
            messageLabel.attributedText = makeMessage(message: base, highlight: schedule, style: style)
            
            proofImageView.image = proofImage
            applyExpanded(isExpanded, animated: false)
            updateBottomAnchorForSchedule(isExpanded: isExpanded)
            
        case let .finishAllSchedule(time, childName, coinEarned):
            timeLabel.setTypo(.body4_12_R, text: time)
            let subject = "\(childName)\(childName.subjectMarker)"
            let base = "\(subject) 하루의 일정을 모두 완료했어요."
            messageLabel.attributedText = makePlainMessage(base, style: style)
            showCoinChip(style: .usedCoinChip, text: "\(coinEarned)개 획득")
            updateBottomAnchorForNormal(hasChip: true)
            
        case let .useCoupon(time, childName, coupon, coinUsed):
            timeLabel.setTypo(.body4_12_R, text: time)
            let subject = "\(childName)\(childName.subjectMarker)"
            let base = "\(subject) \(coupon) 쿠폰을 사용했어요."
            messageLabel.attributedText = makeMessage(message: base, highlight: coupon, style: style)
            showCoinChip(style: .usedCoinChip, text: "\(coinUsed)개 사용")
            updateBottomAnchorForNormal(hasChip: true)
            
        case let .finishMission(time, childName, mission, coinEarned):
            timeLabel.setTypo(.body4_12_R, text: time)
            let subject = "\(childName)\(childName.subjectMarker)"
            let base = "\(subject) \(mission) 미션을 완료했어요."
            messageLabel.attributedText = makeMessage(message: base, highlight: mission, style: style)
            showCoinChip(style: .usedCoinChip, text: "\(coinEarned)개 획득")
            updateBottomAnchorForNormal(hasChip: true)
        }
    }
    
    private func showCoinChip(style: ChipItem.ChipStyle, text: String) {
        coinChip.isHidden = false
        let icon = UIImage(resource: .ic3DCoin)
        coinChip.configure(style: style, icon: icon, text: text)
    }
    
    private func applyExpanded(_ expanded: Bool, animated: Bool) {
        proofImageView.isHidden = !expanded
        proofImageView.snp.updateConstraints { $0.height.equalTo(expanded ? 343 : 0) }
        let name = expanded ? UIImage.icUp : UIImage.icDown
        downButton.setImage(name, for: .normal)
    }
    
    private func updateBottomAnchorForSchedule(isExpanded: Bool) {
        bottomSpacer.snp.remakeConstraints {
            if isExpanded {
                $0.top.equalTo(proofImageView.snp.bottom)
            } else {
                $0.top.equalTo(messageLabel.snp.bottom)
            }
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func updateBottomAnchorForNormal(hasChip: Bool) {
        bottomSpacer.snp.remakeConstraints {
            if hasChip {
                $0.top.equalTo(coinChip.snp.bottom)
            } else {
                $0.top.equalTo(messageLabel.snp.bottom)
            }
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - Action
    
    @objc
    private func didTapToggle() {
        guard downButton.isHidden == false else { return }
        onToggleExpand?()
    }
    
    private func makePlainMessage(_ text: String, style: UIFont.NotoSans) -> NSAttributedString {
        return makeMessage(message: text, highlight: "", style: style)
    }
    
    private func makeMessage(message: String, highlight: String, style: UIFont.NotoSans) -> NSAttributedString {
        let lineHeight = style.size * (style.lineHeightPercent / 100.0)
        let kernValue = style.size * (style.letterSpacingPercent / 100.0)
        let baselineOffset = (lineHeight - style.font.lineHeight) / 4.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        let attr = NSMutableAttributedString(string: message, attributes: [
            .foregroundColor: UIColor.white,
            .font: style.font,
            .kern: kernValue,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: baselineOffset
        ])
        
        let range = (message as NSString).range(of: highlight)
        if range.location != NSNotFound {
            attr.addAttributes([.foregroundColor: UIColor.main], range: range)
        }
        return attr
    }
}
