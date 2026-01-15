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
    
    private let characterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .title2_20_SB
        $0.textColor = .white
        $0.text = "알림장을 분석하고 있어요!"
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
        view.addSubviews(characterImageView, descriptionLabel)
    }
    
    override func setLayout() {
        characterImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(259)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(415)
            $0.height.equalTo(202)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(characterImageView.snp.bottom)
            $0.centerX.equalToSuperview()
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
