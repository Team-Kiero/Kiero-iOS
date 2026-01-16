//
//  GetCoinView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class GetCoinView: BaseUIView {
    
    // MARK: - Properties
    
    // 확인 버튼 클릭 시 ViewController로 이벤트를 전달할 클로저
    var didTapConfirmButton: (() -> Void)?
    
    // MARK: - UI Components
    
    private let dimView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.7)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(resource: .gray900)
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "불 피우기 성공!"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "꾸비에게 불 조각을 건네주고\n보상을 획득했어요."
        $0.textColor = .gray300
        $0.font = .systemFont(ofSize: 14)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    // 코인 보상 영역
    private let coinStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let coinImageView = UIImageView().then {
        // 코인 이미지 리소스가 없다면 시스템 이미지 사용
        $0.image = UIImage(systemName: "circle.circle.fill")
        $0.tintColor = .systemYellow
        $0.contentMode = .scaleAspectFit
    }
    
    private let coinLabel = UILabel().then {
        $0.text = "0 코인"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    // 돌(Stone) 보상 영역
    private let stoneStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    
    private let confirmButton = UIButton(type: .system).then {
        $0.setTitle("확인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .main // 혹은 .blue, .systemBlue
        $0.layer.cornerRadius = 12
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubviews(dimView, containerView)
        containerView.addSubviews(titleLabel, descriptionLabel, coinStackView, stoneStackView, confirmButton)
        
        coinStackView.addArrangedSubviews(coinImageView, coinLabel)
        
        confirmButton.addTarget(self, action: #selector(handleConfirmTap), for: .touchUpInside)
    }
    
    override func setLayout() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(40)
            // 내부 컨텐츠에 따라 높이 유동적 (bottom constraint 필수)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        coinStackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        coinImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        stoneStackView.snp.makeConstraints {
            $0.top.equalTo(coinStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(60) // 돌 이미지 크기에 맞춰 조정
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(stoneStackView.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(20) // 컨테이너 바텀 잡아주기
        }
    }
    
    // MARK: - Configuration
    
    /// ViewModel에서 받은 데이터를 UI에 업데이트합니다.
    func configure(coin: Int, stones: [String]) {
        // 1. 코인 업데이트
        coinLabel.text = "\(coin) 코인"
        
        // 2. 돌(Stones) 업데이트 (기존 뷰 제거 후 다시 생성)
        stoneStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for stone in stones {
            let stoneView = createStoneView(name: stone)
            stoneStackView.addArrangedSubview(stoneView)
        }
    }
    
    /// 돌 이름을 받아 이미지와 라벨로 구성된 뷰를 만듭니다.
    private func createStoneView(name: String) -> UIView {
        let container = UIView()
        
        let imageView = UIImageView().then {
            // 예: "COURAGE" -> UIImage(named: "img_COURAGE") 처럼 매핑
            // 리소스가 없다면 기본 이미지
            $0.image = UIImage(systemName: "hexagon.fill")
            $0.tintColor = .lightGray
            $0.contentMode = .scaleAspectFit
        }
        
        let label = UILabel().then {
            $0.text = name
            $0.textColor = .gray300
            $0.font = .systemFont(ofSize: 10)
            $0.textAlignment = .center
            $0.adjustsFontSizeToFitWidth = true
        }
        
        container.addSubviews(imageView, label)
        
        imageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func handleConfirmTap() {
        didTapConfirmButton?()
    }
}
