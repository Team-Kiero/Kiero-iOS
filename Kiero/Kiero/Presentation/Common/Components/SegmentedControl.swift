//
//  SegmentedControl.swift
//  Kiero
//
//  Created by 신혜연 on 1/10/26.
//

import UIKit

import SnapKit
import Then

final class SegmentedControl: UIView {
    
    // MARK: - Properties
    
    var onIndexChanged: ((Int) -> Void)?
    private var buttons: [UIButton] = []
    private let titles: [String]
    private let contentViews: [UIView]
    
    // MARK: - UI Components
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let contentContainer = UIView()
    
    // MARK: - Life Cycle
    
    init(titles: [String], contentViews: [UIView]) {
        self.titles = titles
        self.contentViews = contentViews
        super.init(frame: .zero)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        self.backgroundColor = .gray900
    }
    
    private func setUI() {
        addSubviews(stackView, underlineView, contentContainer)
        
        titles.enumerated().forEach { index, title in
            let button = UIButton().then {

                $0.setTitleColor(.gray500, for: .normal)
                $0.setTypo(.head2_20_B, text: title, for: .normal)
                $0.setTitleColor(.white, for: .selected)
                $0.setTypo(.head2_20_B, text: title, for: .selected)
                $0.tag = index
                $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            }
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        
        contentViews.enumerated().forEach { index, view in
            contentContainer.addSubview(view)
            view.snp.makeConstraints { $0.edges.equalToSuperview() }
            view.isHidden = (index != 0)
        }
        
        buttons.first?.isSelected = true
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        underlineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalTo(stackView.snp.bottom)
            $0.leading.equalTo(buttons[0].snp.leading)
            $0.trailing.equalTo(buttons[0].snp.trailing)
        }
        
        contentContainer.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func buttonTapped(_ sender: UIButton) {
        updateSelection(sender.tag)
        onIndexChanged?(sender.tag)
    }
    
    func updateSelection(_ index: Int) {
        buttons.enumerated().forEach { i, btn in
            btn.isSelected = (i == index)
        }
        
        contentViews.enumerated().forEach { i, view in
            view.isHidden = (i != index)
        }
        
        let selectedButton = buttons[index]
        
        underlineView.snp.remakeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalTo(stackView.snp.bottom)
            $0.width.equalTo(selectedButton.snp.width)
            $0.leading.equalTo(selectedButton.snp.leading)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
}
