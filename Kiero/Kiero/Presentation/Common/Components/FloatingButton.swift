//
//  FloatingButton.swift
//  Kiero
//
//  Created by 신혜연 on 1/11/26.
//

import UIKit

import SnapKit
import Then

enum FloatingButtonType {
    case schedule
    case mission
}

final class FloatingButton: UIButton {
    
    // MARK: - Properties
    
    var tapAction: (() -> Void)?
    
    // MARK: - Life Cycle
    
    init(type: FloatingButtonType) {
        super.init(frame: .zero)
        
        setStyle(type: type)
        setLayout()
        setAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle(type: FloatingButtonType) {
        switch type {
        case .schedule:
            self.setImage(UIImage(resource: .btnAddSchedule), for: .normal)
        case .mission:
            self.setImage(UIImage(resource: .btnAddMission), for: .normal)
        }
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.size.equalTo(71)
        }
    }
    
    private func setAction() {
        self.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapButton() {
        tapAction?()
    }
}
