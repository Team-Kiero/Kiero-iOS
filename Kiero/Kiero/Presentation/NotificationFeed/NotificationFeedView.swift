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
    
    // MARK: - UI Components
    
    private lazy var profileView = ProfileBox(
        name: "사용자",
        profileURL: "",
        backgroundColor: .clear
    ).then {
        $0.onTap = { [weak self] in
            self?.onProfileTapped?()
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
        addSubviews(profileView, tableView)
        updateProfile()
    }
    
    override func setLayout() {
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(59)
            $0.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(25)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
    }
    
    func updateProfile() {
         let name = TokenManager.shared.getUserName() ?? "사용자"
         let profileURL = TokenManager.shared.getProfile()
         profileView.configure(name: name, url: profileURL)
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
