//
//  TimeSelectionView.swift
//  Kiero
//
//  Created by 신혜연 on 1/13/26.
//

import UIKit

import SnapKit
import Then

final class TimeSelectionView: UIView {
    
    // MARK: - Properties
    
    var startTimeTapAction: (() -> Void)?
    var endTimeTapAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let startTimeField = TimeField().then {
        $0.configure(title: "시작", time: "12 : 00 PM")
        $0.isSelected = false
        $0.isUserInteractionEnabled = true
    }
    
    private let arrowIcon = UIImageView().then {
        $0.image = UIImage(resource: .icRight)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let endTimeField = TimeField().then {
        $0.configure(title: "종료", time: "12 : 00 PM")
        $0.isSelected = false
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setUI()
        setLayout()
        addTarget()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setting Methods
    
    private func setUI() {
        addSubviews(startTimeField, arrowIcon, endTimeField)
    }
    
    private func setLayout() {
        startTimeField.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        endTimeField.snp.makeConstraints {
            $0.trailing.verticalEdges.equalToSuperview()
        }
    }
    
    private func addTarget() {
        let startTap = UITapGestureRecognizer(target: self, action: #selector(didTapStart))
        startTimeField.addGestureRecognizer(startTap)
        
        let endTap = UITapGestureRecognizer(target: self, action: #selector(didTapEnd))
        endTimeField.addGestureRecognizer(endTap)
    }
    
    func updateFieldSelection(isStart: Bool, isSelected: Bool) {
        if isStart {
            startTimeField.isSelected = isSelected
        } else {
            endTimeField.isSelected = isSelected
        }
    }
    
    func updateTime(isStart: Bool, time: String) {
        if isStart {
            startTimeField.configure(title: "시작", time: time)
        } else {
            endTimeField.configure(title: "종료", time: time)
        }
    }
    
    @objc private func didTapStart() {
        startTimeTapAction?()
    }
    
    @objc private func didTapEnd() {
        endTimeTapAction?()
    }
}
