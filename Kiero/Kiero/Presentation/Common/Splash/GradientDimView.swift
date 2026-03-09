//
//  GradientDimView.swift
//  Kiero
//
//  Created by 안치욱 on 3/3/26.
//

import UIKit

final class GradientDimView: UIView {

    private let gradientLayer = CAGradientLayer()

    var maxAlpha: CGFloat = 1 { didSet { updateGradient() } }

    var fadeStartY: CGFloat = 40 { didSet { updateGradient() } }

    var solidStartY: CGFloat = 220 { didSet { updateGradient() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateGradient()
    }

    private func updateGradient() {
        let h = max(bounds.height, 1)

        var l1 = clamp(fadeStartY / h)
        var l2 = clamp(solidStartY / h)

        if l2 < l1 { l2 = l1 }

        let clear = UIColor.kBlack.withAlphaComponent(0).cgColor
        let dim   = UIColor.kBlack.withAlphaComponent(maxAlpha).cgColor

        gradientLayer.colors = [clear, clear, dim, dim]
        gradientLayer.locations = [0, l1 as NSNumber, l2 as NSNumber, 1]
    }

    private func clamp(_ v: CGFloat) -> CGFloat { min(max(v, 0), 1) }
}
