//
//  TabBarView.swift
//  Kiero
//
//  Created by 신혜연 on 1/9/26.
//

import UIKit

import SnapKit
import Then

final class TabBarView: UIView {
    
    // MARK: - Properties
    
    var onTabSelected: ((Int) -> Void)?
    private var itemViews: [TabItem] = []
    private let cornerRadius: CGFloat
    private let isParent: Bool
    
    // MARK: - UI Components
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }

    // MARK: - Life Cycle
    
    init(cornerRadius: CGFloat, isParent: Bool) {
        self.cornerRadius = cornerRadius
        self.isParent = isParent
        super.init(frame: .zero)
        
        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        self.backgroundColor = .kBlack
        if isParent {
            self.layer.cornerRadius = cornerRadius
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            self.layer.shadowColor = UIColor(resource: .gray800).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: -1)
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.5
            
            self.layer.masksToBounds = false
            self.clipsToBounds = false
        } else {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
    }
    
    private func setUI() {
        addSubview(stackView)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setTabItems(titles: [String], icons: [ImageResource]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()
        
        for (index, title) in titles.enumerated() {
            let image = UIImage(resource: icons[index])
            let itemView = TabItem(title: title, image: image)
            itemView.tag = index
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            itemView.addGestureRecognizer(tap)
            itemView.isUserInteractionEnabled = true
            
            stackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
        self.layoutIfNeeded()
    }
    
    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        updateSelection(index)
        onTabSelected?(index)
    }

    func updateSelection(_ index: Int) {
        itemViews.enumerated().forEach { $1.isSelected = ($0 == index) }
    }
}
