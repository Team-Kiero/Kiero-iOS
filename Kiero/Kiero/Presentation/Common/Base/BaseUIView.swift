//
//  BaseUIView.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

class BaseUIView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle() {
        backgroundColor = .kBlack
    }

    func setUI() {}

    func setLayout() {}
}

