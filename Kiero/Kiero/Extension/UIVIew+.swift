//
//  UIVIew+.swift
//  Kiero
//
//  Created by 신혜연 on 1/4/26.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
