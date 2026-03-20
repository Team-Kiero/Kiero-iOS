//
//  CoinMissionView.swift
//  Kiero
//
//  Created by 정윤아 on 1/13/26.
//

import UIKit

import SnapKit
import Then

final class CoinMissionView: BaseUIView {
    
    // MARK: - UI Component
    
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
    
    private let characterImg = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(resource: .imgGoblinCoin)
    }
    
    private let speechField = SpeechField(type: .no)
    
    private let missionLabel = UILabel().then {
        $0.textColor = .white
        $0.setTypo(.title4_14_SB, text: "미션")
    }
    
    private(set) lazy var missionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 27
        $0.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        let estimatedWidth = UIScreen.main.bounds.width - 31
        $0.estimatedItemSize = CGSize(width: estimatedWidth, height: 100)
    }).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.register(DailyMissionCell.self, forCellWithReuseIdentifier: DailyMissionCell.identifier)
    }
    
    private let emptyLabel = UILabel().then {
        $0.textColor = .gray400
        $0.setTypo(.title3_16_SB, text: "아직 등록된 미션이 없어!")
        $0.isHidden = true
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        nameStack.addArrangedSubviews(iconImage, nameLabel)
        addSubviews(
            nameStack,
            coinChip,
            characterImg,
            speechField,
            missionLabel,
            missionCollectionView
        )
        addSubview(emptyLabel)
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
        
        characterImg.snp.makeConstraints {
            $0.top.equalTo(nameStack.snp.bottom).offset(3)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 209, height: 108))
        }
        
        speechField.snp.makeConstraints {
            $0.top.equalTo(nameStack.snp.bottom).offset(82)
            $0.horizontalEdges.equalToSuperview()
        }
        
        missionLabel.snp.makeConstraints {
            $0.top.equalTo(speechField.snp.bottom).offset(27)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        missionCollectionView.snp.makeConstraints {
            $0.top.equalTo(missionLabel.snp.bottom)
            $0.bottom.equalToSuperview().inset(100)
            $0.horizontalEdges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(speechField.snp.bottom).offset(152)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    
    func configureUserInfo(name: String, price: Int) {
        nameLabel.setTypo(.title3_16_SB, text: name)
        coinChip.configure(style: .currentCoinChip, icon: coinImg, text: "\(price) 개")
        
        speechField.configure(
            fieldType: .no,
            name: "꾸비",
            lines: ["우리 함께 멋진 금화를 만들어볼까?"],
            highlightKeywords: ["멋진 금화"]
        )
    }
    
    func updateEmptyState(isEmpty: Bool) {
        missionLabel.isHidden = isEmpty
        missionCollectionView.isHidden = isEmpty
        
        emptyLabel.isHidden = !isEmpty
    }
}
