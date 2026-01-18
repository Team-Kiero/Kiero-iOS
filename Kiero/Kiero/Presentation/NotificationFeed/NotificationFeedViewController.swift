//
//  NotificationFeedViewController.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//

import UIKit

final class NotificationFeedViewController: BaseViewController<NotificationFeedViewModel> {
    
    // MARK: - Properties
    
    private let contentView = NotificationFeedView()
    private let emptyView = EmptyView(text: "아직 아이로부터 도착한 알림이 없어요!")
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = contentView
    }
    
    // MARK: - Setup Methods
    
    override func setDelegate() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }
    
    override func bind(viewModel: NotificationFeedViewModel) {
        super.bind(viewModel: viewModel)
        
        contentView.onProfileTapped = { [weak self] in
            self?.showLogoutDialog {
                self?.performLogout()
            }
        }
        
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                let isEmpty = self.viewModel?.sections.isEmpty ?? true
                
                if isEmpty {
                    self.contentView.tableView.backgroundView = self.emptyView
                } else {
                    self.contentView.tableView.backgroundView = nil
                }
                self.contentView.tableView.reloadData()
            }
        }
        viewModel.fetchNotifications()
    }
}

// MARK: - DataSource

extension NotificationFeedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sections[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationFeedCell.identifier,
            for: indexPath
        ) as? NotificationFeedCell else { return UITableViewCell() }
        
        if let state = viewModel?.sections[indexPath.section].items[indexPath.row] {
            cell.configure(with: state)
        }
        
        cell.onToggleExpand = { [weak self, weak tableView] in
            guard let self, let tableView else { return }
            self.viewModel?.toggleExpansion(at: indexPath)
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return cell
    }
}

// MARK: - Delegate

extension NotificationFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NotificationSectionHeaderView()
        if let date = viewModel?.sections[section].date {
            header.configure(date: date)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

#Preview {
    NotificationFeedViewController(
        viewModel: NotificationFeedViewModel(),
        diContainer: AppDIContainer.shared)
}
