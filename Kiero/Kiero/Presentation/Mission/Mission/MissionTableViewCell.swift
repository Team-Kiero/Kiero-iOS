//
//  MissionTableViewCell.swift
//  Kiero
//
//  Created by 신혜연 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class MissionTableViewCell: UITableViewCell {
    static let identifier = "MissionTableViewCell"
    
    private let missionBox = MissionBoxParent()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setStyle() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setUI() {
        contentView.addSubview(missionBox)
    }
    
    private func setLayout() {
        missionBox.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(17)
        }
    }
    
    func configure(name: String, reward: Int) {
        missionBox.configure(name: name, reward: reward)
    }
}
