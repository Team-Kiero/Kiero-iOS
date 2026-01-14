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
        $0.lineBreakMode = .byTruncatingTail
        $0.textAlignment = .left
    }
    
    private lazy var contentStackView = UIStackView(arrangedSubviews: [dotView, titleLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    // MARK: - Life Cycle
    
    init(name: String, colorCode: String) {
        super.init(frame: .zero)
        let baseColor = UIColor(hex: colorCode)
        
        self.originalText = name
        titleLabel.text = name
        titleLabel.setTypo(.body5_10_R)
        topBar.backgroundColor = baseColor
        dotView.backgroundColor = baseColor
        self.backgroundColor = baseColor.withAlphaComponent(0.2)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyOverflowIfNeeded()
    }
    
//    override func setStyle() {
//        self.layer.cornerRadius = 5
//        self.clipsToBounds = true
//    }
    
    override func setUI() {
        addSubviews(topBar, contentStackView)
    }
    
    override func setLayout() {
        topBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(5)
        }
        
        dotView.snp.makeConstraints {
            $0.size.equalTo(5)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(2)
            $0.trailing.lessThanOrEqualToSuperview().inset(2)
            $0.bottom.lessThanOrEqualToSuperview().inset(1)
        }
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func applyOverflowIfNeeded() {
        guard let text = originalText as String? else { return }

        titleLabel.text = text

        let availableHeight = bounds.height - 10
        let targetWidth = titleLabel.bounds.width

        let fittedSize = titleLabel.sizeThatFits(
            CGSize(width: targetWidth, height: .greatestFiniteMagnitude)
        )

        if fittedSize.height > availableHeight {
            titleLabel.text = truncatedText(text)
        }
    }

    private func truncatedText(_ text: String) -> String {
        guard text.count > 2 else { return text }
        let prefix = text.prefix(2)
        return "\(prefix)..."
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
