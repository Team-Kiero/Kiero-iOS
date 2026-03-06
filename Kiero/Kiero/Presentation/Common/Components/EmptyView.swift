//
//  EmptyView.swift
//  Kiero
//
//  Created by 신혜연 on 1/14/26.
//

import UIKit

import SnapKit
import Then

final class EmptyView: BaseUIView {
    
    // MARK: - UI Components
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .gray400
        $0.numberOfLines = 0
    }
    
    private let characterImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgGoblinSideview)
        $0.contentMode = .scaleAspectFit
    }
    
    private let containerStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    // MARK: - Life Cycle
    
    init(text: String) {
        super.init(frame: .zero)
        self.descriptionLabel.setTypo(.title3_16_SB, text: text)
        self.descriptionLabel.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setting Methods
    
    override func setUI() {
        containerStackView.addArrangedSubviews(descriptionLabel, characterImageView)
        addSubview(containerStackView)
    }
    
    override func setLayout() {
        characterImageView.snp.makeConstraints {
            $0.size.equalTo(251)
        }
        
        containerStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

#Preview {
    EmptyView(text: "등록된 미션이 없어요.\n우측 하단 버튼을 눌러 미션을 추가해보세요!")
}
