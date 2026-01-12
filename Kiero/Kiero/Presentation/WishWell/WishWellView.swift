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
    
    private let iconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(resource: .icKidProfile)
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
    }
    
    private let nameStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    private let coinChip = ChipItem()
    
    private let coinImg = UIImage(resource: .ic3DCoin)
    
    private let wishWellIcon = UIImage(resource: .icStarRound)
    
    private let wishWellLabel = UILabel().then {
        $0.textColor = .white
        $0.setTypo(.title2_20_SB, text: "소원의 우물")
    }
    
    private let wishWellStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    private let wishMessage = UILabel().then {
        $0.textColor = .gray300
        $0.setTypo(.body4_12_R, text: "미션을 통해 얻은 금화로 소원을 살 수 있어!")
    }
    
    private let totalStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 14
    }
    
    private let container = UIView().then {
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .gray900
    }
    
    private let line = UILabel().then {
        $0.backgroundColor = .gray900
    }
    
    private lazy var wishCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 13
        $0.sectionInset = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
    }).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        
        $0.register(WishWellCell.self, forCellWithReuseIdentifier: WishWellCell.identifier)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
