//
//  WishWellView.swift
//  Kiero
//
//  Created by 정윤아 on 1/11/26.
//

import UIKit

import SnapKit
import Then

final class WishWellView: BaseUIView {
    
    // MARK: - UI Component
    
    private let wishEmptyView = ContentEmptyView(
        title: "아직 등록된 보상이 없어!",
        description: "부모님과 함께 나만의 보상을 정해볼까?",
        topOffset: 353
    )
    
    private let iconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(resource: .icKidProfile)
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
    }
    
    private let nameStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    private let coinChip = ChipItem()
    
    private let coinImg = UIImage(resource: .ic3DCoin)
    
    private let wishWellIcon = UIImageView().then {
        $0.image = UIImage(resource: .icStarRound)
    }
    
    private let wishWellLabel = UILabel().then {
        $0.textColor = .white
        $0.setTypo(.title2_20_SB, text: "소원의 우물")
    }
    
    private let wishWellStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }
    
    private let wishMessage = UILabel().then {
        $0.textColor = .gray300
        $0.setTypo(.body4_12_R, text: "미션을 통해 얻은 금화로 소원을 살 수 있어!")
    }
    
    private let totalStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 14
    }
    
    private let container = UIView().then {
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .gray900
    }
    
    private let line = UIView().then {
        $0.backgroundColor = .gray900
    }
    
    private(set) lazy var wishCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 13
        $0.sectionInset = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
    }).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        
        $0.register(WishWellCell.self, forCellWithReuseIdentifier: WishWellCell.identifier)
    }
    
    // MARK: - Setup Method
    
    override func setUI() {
        addSubviews(wishEmptyView, nameStack, coinChip, container, line, wishCollectionView)
        nameStack.addArrangedSubviews(iconImage, nameLabel)
        wishWellStack.addArrangedSubviews(wishWellIcon, wishWellLabel)
        totalStack.addArrangedSubviews(wishWellStack, wishMessage)
        container.addSubview(totalStack)
    }
    
    override func setLayout() {
        nameStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(59)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        iconImage.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        coinChip.snp.makeConstraints {
            $0.centerY.equalTo(nameStack)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        wishWellIcon.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(nameStack.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(147)
        }
        
        totalStack.snp.makeConstraints {
            $0.top.equalTo(container.snp.top).offset(27)
            $0.centerX.equalTo(container)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(container.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(2)
        }
        
        wishCollectionView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
        
        wishEmptyView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    
    func configureUserInfo(name: String, price: Int) {
        nameLabel.setTypo(.title3_16_SB, text: name)
        coinChip.configure(style: .currentCoinChip, icon: coinImg, text: "\(price) 개")
    }
    
    // MARK: - Methods
    
    func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            wishEmptyView.isHidden = false
            wishCollectionView.isHidden = true
        } else {
            wishEmptyView.isHidden = true
            wishCollectionView.isHidden = false
        }
    }
}
