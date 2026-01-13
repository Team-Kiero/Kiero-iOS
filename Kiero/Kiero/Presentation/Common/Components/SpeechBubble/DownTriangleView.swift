//
//  DownTriangleView.swift
//  Kiero
//
//  Created by 안치욱 on 1/14/26.
//


import UIKit

final class DownTriangleView: UIView {

    // MARK: - Public Properties

    var fillColor: UIColor = .gray900 {
        didSet { shapeLayer.fillColor = fillColor.cgColor }
    }

    var cornerRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    // MARK: - Private

    private let shapeLayer = CAShapeLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        shapeLayer.fillColor = fillColor.cgColor
        layer.addSublayer(shapeLayer)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = makePath(in: bounds).cgPath
    }

    // MARK: - Path

    private func makePath(in rect: CGRect) -> UIBezierPath {
        let r = min(cornerRadius, min(rect.width, rect.height) / 2)
        let path = UIBezierPath()

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)

        path.move(to: CGPoint(x: topLeft.x + r, y: topLeft.y))
        path.addLine(to: CGPoint(x: topRight.x - r, y: topRight.y))
        path.addQuadCurve(
            to: CGPoint(x: topRight.x, y: topRight.y + r),
            controlPoint: topRight
        )
        path.addLine(to: CGPoint(x: bottom.x + r, y: bottom.y - r))
        path.addQuadCurve(
            to: CGPoint(x: bottom.x - r, y: bottom.y - r),
            controlPoint: bottom
        )
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + r))
        path.addQuadCurve(
            to: CGPoint(x: topLeft.x + r, y: topLeft.y),
            controlPoint: topLeft
        )

        path.close()
        return path
    }
}
