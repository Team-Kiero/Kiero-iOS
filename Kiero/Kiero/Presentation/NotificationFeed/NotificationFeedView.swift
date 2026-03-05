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
    
    // MARK: - Properties
    
    var onProfileTapped: (() -> Void)?
    var onBackTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var navigationBar = NavigationBar(type: .back(title: "알림")).then {
        $0.leftButtonAction = { [weak self] in
            print("🔧 네비게이션 바 백 버튼 클릭됨")
            self?.onBackTapped?()
        }
    }
    
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
        addSubviews(navigationBar, tableView)
    }
    
    override func setLayout() {
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(13)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    func applySnapshot() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc
    private func handleTap() {
        onProfileTapped?()
    }
}
