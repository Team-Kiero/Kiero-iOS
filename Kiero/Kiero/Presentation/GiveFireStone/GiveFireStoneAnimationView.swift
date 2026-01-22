//
//  GiveFireStoneAnimationView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class GiveFireStoneAnimationView: BaseUIView {
    
    // MARK: - UI Components
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgBackground)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let backgroundMaskView = UIView().then {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.type = .radial
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        
        $0.layer.addSublayer(gradientLayer)
    }
    
    private let giveSpeechBubble = SpeechBubble(speech: "불조각을 나에게 건네줘!")
    
    private let kkubiImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(resource: .imgGoblinKid)
    }
    
    private let stoneImages: [UIImage] = [
        UIImage(resource: .ic3DBluestone),
        UIImage(resource: .ic3DGreenstone),
        UIImage(resource: .ic3DRedstone)
    ]
    
    private let fireStoneImageView = UIImageView().then {
        $0.image = UIImage(resource: .ic3DBluestone)
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0
    }
    
    private let nameView = UIView().then {
        $0.backgroundColor = UIColor(resource: .gray900)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.setTypo(.body5_10_R, text: "꾸비")
    }
    
    // MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundMaskView.frame = backgroundImageView.bounds
        
        if let gradientLayer = backgroundMaskView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundMaskView.bounds
        }
        
        backgroundImageView.mask = backgroundMaskView
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        self.backgroundColor = .kBlack
    }
    
    override func setUI() {
        addSubviews(backgroundImageView, kkubiImageView, giveSpeechBubble, nameView, fireStoneImageView)
        nameView.addSubview(nameLabel)
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.width.equalTo(483)
            $0.height.equalTo(508)
            $0.leading.equalToSuperview().offset(-54)
            $0.top.equalToSuperview().offset(102)
        }
        
        giveSpeechBubble.snp.makeConstraints {
            $0.top.equalToSuperview().offset(227)
            $0.centerX.equalToSuperview()
        }
        
        kkubiImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(11)
            $0.top.equalToSuperview().offset(289)
        }
        
        nameView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(59)
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().offset(-180)
        }
        
        nameLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        fireStoneImageView.snp.makeConstraints {
            $0.centerX.equalTo(kkubiImageView)
            $0.centerY.equalTo(kkubiImageView).offset(60)
            $0.size.equalTo(70)
        }
    }
    
    // MARK: - Animation Methods
    
    private func stoneImage(for key: String) -> UIImage {
        switch key {
        case "COURAGE":
            return UIImage(resource: .ic3DBluestone)
        case "WISDOM":
            return UIImage(resource: .ic3DGreenstone)
        case "GRIT":
            return UIImage(resource: .ic3DRedstone)
        default:
            return UIImage(resource: .ic3DBluestone)
        }
    }
    
    func playAnimation(stones: [String], completion: (() -> Void)? = nil) {
        self.layoutIfNeeded()
        
        guard !stones.isEmpty else {
            completion?()
            return
        }
        
        let startY = kkubiImageView.frame.maxY > 0 ? kkubiImageView.frame.maxY : 500
        let targetY = fireStoneImageView.frame.midY
        let distanceY = (startY - targetY) * 0.2
        let images = stones.map { stoneImage(for: $0) }
        
        runAnimationLoop(images: images, distanceY: distanceY, currentIndex: 0, completion: completion)
    }
    
    
    private func runAnimationLoop(images: [UIImage], distanceY: CGFloat, currentIndex: Int, completion: (() -> Void)?) {
        guard currentIndex < images.count else {
            UIView.animate(withDuration: 0.3) {
                self.fireStoneImageView.alpha = 0
            } completion: { _ in
                completion?()
            }
            return
        }
        
        self.fireStoneImageView.image = images[currentIndex]
        
        let rotation = CGAffineTransform(rotationAngle: -30 * .pi / 180)
        let translation = CGAffineTransform(translationX: 0, y: distanceY)
        let startTransform = rotation.concatenating(translation)
        
        self.fireStoneImageView.transform = startTransform
        self.fireStoneImageView.alpha = 1
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
            self.fireStoneImageView.transform = .identity
        } completion: { _ in
            self.runAnimationLoop(images: images,
                                  distanceY: distanceY,
                                  currentIndex: currentIndex + 1,
                                  completion: completion)
        }
    }
    
}
