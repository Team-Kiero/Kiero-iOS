//
//  LoadingViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class LoadingViewController: BaseViewController<LoadingViewModel> {
    
    // MARK: - UI Components
    
    private let containerStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 17
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let characterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .white
        $0.setTypo(.title2_20_SB, text: "알림장을 분석하고 있어요!")
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGIFImage()
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        view.addSubview(containerStackView)
        containerStackView.addArrangedSubviews(characterImageView, descriptionLabel)
    }
    
    override func setLayout() {
        containerStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(298)
            $0.centerX.equalToSuperview()
        }
        
        characterImageView.snp.makeConstraints {
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-17)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(450)
            $0.height.equalTo(150)
        }
    }
    
    private func setGIFImage() {
        if let url = Bundle.main.url(forResource: "parent", withExtension: "gif") {
                let resource = LocalFileImageDataProvider(fileURL: url)
                
                characterImageView.kf.setImage(
                    with: resource,
                    options: [
                        .cacheOriginalImage,
                        .transition(.fade(0.2))
                    ]
                )
            }
        }
}

#Preview {
    AppDIContainer.shared.makeLoadingViewController()
}
