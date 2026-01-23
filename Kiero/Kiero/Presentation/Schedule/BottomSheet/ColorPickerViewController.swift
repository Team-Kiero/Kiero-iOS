//
//  ColorPickerViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/14/26.
//

import UIKit

import SnapKit
import Then

final class ColorPickerViewController: BaseBottomSheetViewController {
    
    // MARK: - Properties
    
    var initialSelectedColor: UIColor?
    var onColorSelected: ((UIColor) -> Void)?
    var onDismiss: (() -> Void)?
    
    private let availableColors: [UIColor] = [
        .schedule1,
        .schedule2,
        .schedule3,
        .schedule4,
        .schedule5
    ]
    
    private var selectedColor: UIColor?
    private var colorChips: [ColorChip] = []
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .closeDone(title: "컬러"), backgroundColor: .gray900)
    
    private let colorStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 23
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyle()
        setUI()
        setLayout()
        setAction()
        configureChips()
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        navigationBar.updateTitle("컬러")
    }
    
    private func setUI() {
        containerView.addSubviews(navigationBar, colorStackView)
    }
    
    private func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(32)
        }
        
        colorStackView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(25)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(175)
        }
    }
    
    private func setAction() {
        navigationBar.leftButtonAction = {
            super.hideSheet()
        }
        
        navigationBar.rightButtonAction = { [weak self] in
            self?.hideSheet()
        }
    }
    
    private func configureChips() {
        availableColors.forEach { color in
            let chip = ColorChip()
            let isInitiallySelected = (color == initialSelectedColor)
            chip.configure(with: color, isSelected: isInitiallySelected)

            if isInitiallySelected { self.selectedColor = color }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChip(_:)))
            chip.addGestureRecognizer(tapGesture)
            chip.isUserInteractionEnabled = true
            
            colorChips.append(chip)
            colorStackView.addArrangedSubview(chip)
        }
    }
    
    @objc
    private func didTapChip(_ gesture: UITapGestureRecognizer) {
        guard let tappedChip = gesture.view as? ColorChip else { return }
        
        colorChips.forEach { $0.isSelected = ($0 == tappedChip) }
        self.selectedColor = tappedChip.backgroundColor
    }
    
    override func hideSheet() {
        if let color = self.selectedColor {
            self.onColorSelected?(color)
        }
        
        self.onDismiss?()
        super.hideSheet()
    }
}
