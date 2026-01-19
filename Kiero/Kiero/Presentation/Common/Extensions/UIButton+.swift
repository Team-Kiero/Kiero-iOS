//
//  UIButton+.swift
//  Kiero
//
//  Created by 정윤아 on 1/19/26.
//

import UIKit

extension UIButton {
    func setTypo(_ style: UIFont.NotoSans, text: String? = nil, for state: UIControl.State = .normal) {
        let targetText = text ?? self.title(for: state) ?? ""
        
        let attributedString = NSMutableAttributedString(string: targetText)
        let paragraphStyle = NSMutableParagraphStyle()
        
        let lineHeight = style.size * (style.lineHeightPercent / 100.0)
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = .center
        
        let baselineOffset = (lineHeight - style.font.lineHeight) / 4.0
        let kernValue = style.size * (style.letterSpacingPercent / 100.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .paragraphStyle: paragraphStyle,
            .kern: kernValue,
            .baselineOffset: baselineOffset,
            .foregroundColor: self.titleColor(for: state) ?? .white
        ]
        
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
        
        self.setAttributedTitle(attributedString, for: state)
    }
}
