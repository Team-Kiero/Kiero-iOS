//
//  NotificationFeedView.swift
//  Kiero
//
//  Created by 정윤아 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class NotificationFeedView: BaseUIView {
    
    // MARK: - UI Components
    
    private let profileView = ProfileBox(name: "윤아", profileURL: "")
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(NotificationFeedCell.self, forCellReuseIdentifier: NotificationFeedCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        backgroundColor = .kBlack
    }
    
    override func setUI() {
        addSubviews(profileView, tableView)
    }
    
    override func setLayout() {
        profileView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
            $0.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(25)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
    }
}
