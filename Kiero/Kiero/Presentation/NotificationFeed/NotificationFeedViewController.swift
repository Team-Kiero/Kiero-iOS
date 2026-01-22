//
//  NotificationFeedViewController.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//

import Combine
import UIKit

final class NotificationFeedViewController: BaseViewController<NotificationFeedViewModel> {
    
    // MARK: - Properties
    
    private let contentView = NotificationFeedView()
    private let emptyView = EmptyView(text: "아직 아이로부터 도착한 알림이 없어요!")
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Life Cycle
    
    override func loadView() { view = contentView }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentView.updateProfile()
        refreshSubject.send(())
    }
    
    // MARK: - Setup Methods
    
    override func setDelegate() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.showsVerticalScrollIndicator = false
    }
    
    override func bind(viewModel: NotificationFeedViewModel) {
        super.bind(viewModel: viewModel)
        
        contentView.onProfileTapped = { [weak self] in
            self?.showLogoutDialog {
                self?.viewModel?.performLogout()
            }
        }
        
        let input = NotificationFeedViewModel.Input(
            viewDidload: viewDidLoadSubject.eraseToAnyPublisher(),
            refresh: refreshSubject.eraseToAnyPublisher(),
            loadMore: loadMoreSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.contentView.applySnapshot()
            }
            .store(in: &cancellables)
        
        viewDidLoadSubject.send(())
        
        viewModel.logoutSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigateToPickRole()
            }
            .store(in: &cancellables)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            loadMoreSubject.send(())
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

extension NotificationFeedViewController: ScrollToTopAvailable {
    func scrollToTop() {
        if viewModel?.sections.isEmpty == false {
            contentView.tableView.setContentOffset(.zero, animated: false)
        }
    }
}
