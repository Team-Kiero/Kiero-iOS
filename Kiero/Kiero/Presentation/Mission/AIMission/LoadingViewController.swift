//
//  LoadingViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import Kingfisher
import KingfisherWebP
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
    
    private let characterImageView = AnimatedImageView().then {
        $0.contentMode = .scaleAspectFit
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
        
        setWebPImage()
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
    
    override func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.timeoutTrigger
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                Toast.show(message: "잠시 후 다시 시도해주세요")
                self?.dismiss(animated: false)
            }
            .store(in: &cancellables)
    }
    
    private func setWebPImage() {
        guard let url = Bundle.main.url(forResource: "parent", withExtension: "webp") else { return }
        
        let processor = WebPProcessor.default
        let serializer = WebPSerializer.default
        
        characterImageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .cacheSerializer(serializer)
            ]
        )
    }
}

#Preview {
    AppDIContainer.shared.makeLoadingViewController()
}
