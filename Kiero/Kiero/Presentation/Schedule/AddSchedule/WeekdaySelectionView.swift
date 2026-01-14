//
//  WeekdaySelectionView.swift
//  Kiero
//
//  Created by 신혜연 on 1/13/26.
//

import UIKit

import SnapKit
import Then

final class WeekdaySelectionView: UIView {
    
    // MARK: - Properties
    
    private let days = ["월", "화", "수", "목", "금", "토", "일"]
    private var dayButtons: [UIButton] = []
    
    private(set) var selectedIndices = Set<Int>()
    
    // MARK: - UI Components
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var everyDayButton = UIButton().then {
        $0.setTitle("매일", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .body5_10_R
        $0.setImage(UIImage(resource: .btnUncheck), for: .normal)
        $0.setImage(UIImage(resource: .btnCheck), for: .selected)
        $0.semanticContentAttribute = .forceLeftToRight
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        $0.addTarget(self, action: #selector(everyDayTapped), for: .touchUpInside)
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        days.enumerated().forEach { index, title in
            let button = UIButton().then {
                $0.setTitle(title, for: .normal)
                $0.titleLabel?.font = .body1_18_R
                $0.setTitleColor(.gray700, for: .normal)
                $0.setTitleColor(.main, for: .selected)
                $0.backgroundColor = .gray900
                $0.layer.cornerRadius = 21
                $0.layer.borderColor = UIColor.main.cgColor
                $0.layer.borderWidth = 0
                $0.tag = index
                $0.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
            }
            dayButtons.append(button)
            stackView.addArrangedSubview(button)
            
            button.snp.makeConstraints { $0.size.equalTo(42) }
        }
        
        addSubviews(stackView, everyDayButton)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        everyDayButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(18)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func dayButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.layer.borderWidth = sender.isSelected ? 1.0 : 0
        
        if sender.isSelected {
            selectedIndices.insert(sender.tag)
        } else {
            selectedIndices.remove(sender.tag)
        }
        
        everyDayButton.isSelected = (selectedIndices.count == 7)
    }
    
    @objc
    private func everyDayTapped() {
        everyDayButton.isSelected.toggle()
        let isSelectAll = everyDayButton.isSelected
        
        dayButtons.forEach { button in
            button.isSelected = isSelectAll
            button.layer.borderWidth = isSelectAll ? 1.0 : 0
            
            if isSelectAll {
                selectedIndices.insert(button.tag)
            } else {
                selectedIndices.remove(button.tag)
            }
        }
    }
}
