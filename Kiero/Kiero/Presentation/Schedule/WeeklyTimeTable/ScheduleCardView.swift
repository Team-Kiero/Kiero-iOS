//
//  ScheduleCardView.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import UIKit

import SnapKit
import Then

final class ScheduleCardView: BaseUIView {
    
    // MARK: - Properties
    
    private var originalText: String = ""
    var tapAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let topBar = UIView()
    
    private let dotView = UIView().then {
        $0.layer.cornerRadius = 2.5
        $0.layer.shadowColor = UIColor(hex: "#00FFE1").cgColor
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowOffset = .zero
        $0.layer.shadowRadius = 2
        $0.layer.masksToBounds = false
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textColor = .white
        $0.lineBreakMode = .byCharWrapping
        $0.textAlignment = .center
    }
    
    private lazy var contentStackView = UIStackView(arrangedSubviews: [dotView, titleLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .top
        $0.distribution = .fill
    }
    
    // MARK: - Life Cycle
    
    init(name: String, color: UIColor) {
        super.init(frame: .zero)
        
        self.originalText = name
        titleLabel.setTypo(.body5_11_R, text: name)
        
        topBar.backgroundColor = color
        dotView.backgroundColor = color
        
        self.backgroundColor = color.withAlphaComponent(0.2)
        
        setAction()
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyDynamicTextLogic()
    }
    
    override func setStyle() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    override func setUI() {
        addSubviews(topBar, contentStackView)
    }
    
    override func setLayout() {
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(3)
            $0.trailing.lessThanOrEqualToSuperview().inset(3)
            $0.bottom.lessThanOrEqualToSuperview().inset(2)
        }
        
        topBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(4)
        }
        
        dotView.snp.makeConstraints {
            $0.size.equalTo(4)
        }
    }
    
    private func setAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    private func applyDynamicTextLogic() {
        let cardHeight = bounds.height
        
        if cardHeight < 20 {
            titleLabel.isHidden = true
            dotView.isHidden = true
            return
        }
        
        titleLabel.isHidden = false
        dotView.isHidden = false
        
        if cardHeight < 38 {
            titleLabel.numberOfLines = 1
            if originalText.count >= 4 {
                titleLabel.text = "\(originalText.prefix(2))..."
            } else {
                titleLabel.text = originalText
            }
        } else {
            titleLabel.numberOfLines = 2
            
            var processedText = originalText
            
            if originalText.count >= 7 {
                processedText = String(originalText.prefix(5)) + "..."
            }
            
            if processedText.count == 4 {
                let splitIndex = processedText.index(processedText.startIndex, offsetBy: 2)
                let firstLine = processedText[..<splitIndex]
                let secondLine = processedText[splitIndex...]
                titleLabel.text = "\(firstLine)\n\(secondLine)"
            } else if processedText.count >= 3 {
                let splitIndex = processedText.index(processedText.startIndex, offsetBy: 3)
                let firstLine = processedText[..<splitIndex]
                let secondLine = processedText[splitIndex...]
                titleLabel.text = "\(firstLine)\n\(secondLine)"
            } else {
                titleLabel.text = processedText
            }
        }
        
        dotView.transform = CGAffineTransform(translationX: 0, y: 5.5)
    }
    
    @objc private func didTapCard() {
        tapAction?()
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") { hexSanitized.remove(at: hexSanitized.startIndex) }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
