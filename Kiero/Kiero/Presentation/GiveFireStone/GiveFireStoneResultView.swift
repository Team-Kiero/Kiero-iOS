//
//  GiveFireStoneResultView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import ImageIO
import UIKit

import Kingfisher
import SnapKit
import Then

final class GiveFireStoneResultView: BaseUIView {
    
    // MARK: - Properties
    
    var didTapClose: (() -> Void)?
    
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
    
    private let kkubiImageView = AnimatedImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let speechField = SpeechField(type: .no).then {
        $0.isHidden = false
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
        self.backgroundColor = UIColor(resource: .kBlack)
    }
    
    override func setUI() {
        addSubviews(backgroundImageView, kkubiImageView, speechField)
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.width.equalTo(483)
            $0.height.equalTo(508)
            $0.leading.equalToSuperview().offset(-54)
            $0.top.equalToSuperview().offset(102)
        }
        
        kkubiImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(11)
            $0.top.equalToSuperview().offset(289)
            $0.height.equalTo(352)
        }
        
        speechField.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(107)
        }
    }
    
    // MARK: - Configuration
    
    func configure(coin: Int, stones: [String]) {
        let stoneNames = stones.map { mapStoneName($0) }.joined(separator: ", ")
        
        let lines: [String]
        let highlightKeywords: [String]
        
        if coin > 0 {
            lines = [
                "덕분에 영웅의 불꽃 이 커졌어!",
                "선물로 금화 \(coin)개를 줄게"
            ]
            highlightKeywords = ["영웅의 불꽃"]
        } else {
            lines = [
                "덕분에 영웅의 불꽃 이 커졌어!",
                "오늘도 도와줘서 고마워"
            ]
            highlightKeywords = ["영웅의 불꽃"]
        }
        
        speechField.configure(
            fieldType: .no,
            name: "꾸비",
            lines: lines,
            highlightKeywords: highlightKeywords
        )
    }
    
    private func mapStoneName(_ key: String) -> String {
        switch key {
        case "COURAGE": return "용기의 불꽃"
        case "WISDOM": return "지혜의 불꽃"
        case "GRIT": return "인내의 불꽃"
        default: return "영웅의 불꽃"
        }
    }
    
    func playGif() {
        kkubiImageView.stopAnimating()
        kkubiImageView.image = nil
        
        guard let url = Bundle.main.url(forResource: "kkubi_fire", withExtension: "gif") else { return }
        
        kkubiImageView.kf.setImage(with: url)
        kkubiImageView.repeatCount = .once
        
        let gifDuration = getGifDuration(from: url)
        
        print("GIF 재생 시간: \(gifDuration)초")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + gifDuration + 0.5) { [weak self] in
            print("애니메이션 종료! 닫기 신호 보냄")
            self?.didTapClose?()
        }
    }
    
    private func getGifDuration(from url: URL) -> TimeInterval {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return 0.0 }
        let count = CGImageSourceGetCount(source)
        var totalDuration: TimeInterval = 0.0
        
        for i in 0..<count {
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                
                var delay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
                ?? gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double
                ?? 0.1
                
                if delay < 0.011 { delay = 0.1 }
                
                totalDuration += delay
            }
        }
        return totalDuration
    }
}
