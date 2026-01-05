//
//  UILabel+.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/5/26.
//

import UIKit

extension UILabel {
    func setTypo(_ style: UIFont.NotoSans, text: String? = nil) {
        let targetText = text ?? self.text ?? ""
        
        let attributedString = NSMutableAttributedString(string: targetText)
        let paragraphStyle = NSMutableParagraphStyle()
        
        let lineHeight = style.size * (style.lineHeightPercent / 100.0)
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        let baselineOffset = (lineHeight - style.font.lineHeight) / 4.0
        
        let kernValue = style.size * (style.letterSpacingPercent / 100.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .paragraphStyle: paragraphStyle,
            .kern: kernValue,
            .baselineOffset: baselineOffset
        ]
        
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
        
        self.attributedText = attributedString
    }
}
