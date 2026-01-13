//
//  UIImage+.swift
//  Kiero
//
//  Created by 안치욱 on 1/13/26.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale

        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
