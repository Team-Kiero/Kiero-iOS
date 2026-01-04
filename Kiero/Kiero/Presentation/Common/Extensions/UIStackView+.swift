//
//  UIStackView+.swift
//  Kiero
//
//  Created by 신혜연 on 1/4/26.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { self.addArrangedSubview($0) }
    }
}
