//
//  ChipItem.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/10/26.
//

import UIKit

import SnapKit
import Then

final class ChipItem: UIView {
    
    // MARK: State
    
    enum ChipStyle {
        case currentCoinChip
        case usedCoinChip
        case inProgressChip
        case highlightChip
        case completedChip
        
        var height: CGFloat {
            switch self {
            case .usedCoinChip:
                return 24
            default:
                return 28
            }
        }
        
        var iconSize: CGSize {
            switch self {
            case .usedCoinChip:
                return CGSize(width: 16, height: 16)
                
            case .currentCoinChip:
                return CGSize(width: 20, height: 20)
                
            case .inProgressChip, .highlightChip, .completedChip:
                return CGSize(width: 19, height: 23)
            }
        }
        
        var font: UIFont.NotoSans {
            switch self {
            case .usedCoinChip:
                return .body6_10_R
            default:
                return .body3_14_R
            }
        }
    }
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let textLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setStyle (_ style: ChipStyle) {
        containerView.layer.borderWidth = 1
        containerView.layer.shadowOpacity = 0
        containerView.backgroundColor = UIColor.gray900
        
        switch style {
        case .usedCoinChip:
            containerView.layer.borderColor = UIColor.gray500.cgColor
            containerView.backgroundColor = .gray900
            textLabel.textColor = .gray500
            
        case .highlightChip:
            containerView.layer.borderColor = UIColor.main.cgColor
            textLabel.textColor = UIColor.main
            iconImageView.alpha = 1.0
            containerView.layer.shadowColor = UIColor.main.cgColor
            containerView.layer.shadowOffset = .zero
            containerView.layer.shadowRadius = 4
            containerView.layer.shadowOpacity = 1
            containerView.clipsToBounds = false
            
        default:
            containerView.layer.borderColor = UIColor.gray100.cgColor
            textLabel.textColor = .gray100
            iconImageView.alpha = 1.0
        }
    }
    
    private func setUI() {
        addSubview(containerView)
        containerView.addSubview(contentStackView)
        contentStackView.addArrangedSubviews(iconImageView, textLabel)
    }
    
    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
    }
    
    func configure(style: ChipStyle, icon: UIImage, text: String) {
        textLabel.setTypo(style.font, text: text)
        
        iconImageView.image = icon
        iconImageView.isHidden = false
        
        iconImageView.snp.remakeConstraints {
            $0.size.equalTo(style.iconSize)
        }
        
        setStyle(style)
        
        containerView.layer.cornerRadius = style.height / 2
        
        containerView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(style.height)
        }
    }
}
