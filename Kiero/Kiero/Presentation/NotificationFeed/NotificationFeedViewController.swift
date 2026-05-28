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
    private let viewWillDisappearSubject = PassthroughSubject<Void, Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    
    private var renderedSections: [FeedSection] = []
    
    var deepLinkTargetId: Int64?
    
    // MARK: - Life Cycle
    
    override func loadView() { view = contentView }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearSubject.send(())
    }
    
    // MARK: - Setup Methods
    
    override func setDelegate() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.showsVerticalScrollIndicator = false
    }
    
    override func bind(viewModel: NotificationFeedViewModel) {
        super.bind(viewModel: viewModel)
        
        contentView.onBackTapped = { [weak self] in
            guard let self = self else { return }
            
            if let navigationController = self.navigationController,
               navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        let input = NotificationFeedViewModel.Input(
            viewDidload: viewDidLoadSubject.eraseToAnyPublisher(),
            viewWillDisappear: viewWillDisappearSubject.eraseToAnyPublisher(),
            refresh: refreshSubject.eraseToAnyPublisher(),
            loadMore: loadMoreSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .receive(on: RunLoop.main)
            .sink { [weak self] sections in
                guard let self else { return }
                
                self.renderedSections = sections
                self.contentView.tableView.reloadData()
                
                let isEmpty = sections.isEmpty || sections.allSatisfy { $0.items.isEmpty }
                self.updateEmptyView(isEmpty: isEmpty)
                
                if let targetId = self.deepLinkTargetId,
                   !sections.isEmpty,
                   sections.contains(where: { !$0.items.isEmpty }) {
                    self.scrollToFeedAndExpand(targetId: targetId)
                    self.deepLinkTargetId = nil
                }
            }
            .store(in: &cancellables)
        
        viewDidLoadSubject.send(())
    }
    
    private func scrollToFeedAndExpand(targetId: Int64) {
        
        for (sectionIndex, section) in renderedSections.enumerated() {
            for (rowIndex, item) in section.items.enumerated() {
                if case .finishSchedule(_, _, _, _, _, _, let scheduleDetailId) = item,
                   scheduleDetailId == targetId {
                    
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.contentView.tableView.scrollToRow(
                            at: indexPath,
                            at: .middle,
                            animated: true
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.viewModel?.toggleExpansion(at: indexPath)
                            
                            UIView.performWithoutAnimation {
                                self.contentView.tableView.reloadRows(at: [indexPath], with: .none)
                                self.contentView.tableView.beginUpdates()
                                self.contentView.tableView.endUpdates()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.contentView.tableView.scrollToRow(
                                    at: indexPath,
                                    at: .bottom,
                                    animated: true
                                )
                            }
                        }
                    }
                    return
                }
            }
        }
    }
    
    private func updateEmptyView(isEmpty: Bool) {
        contentView.tableView.backgroundView = isEmpty ? emptyView : nil
        contentView.tableView.separatorStyle = .none
    }
    
    func triggerRefresh() {
        refreshSubject.send(())
    }
}

// MARK: - DataSource

extension NotificationFeedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return renderedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return renderedSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationFeedCell.identifier,
            for: indexPath
        ) as? NotificationFeedCell else { return UITableViewCell() }
        
        let state = renderedSections[indexPath.section].items[indexPath.row]
        cell.configure(with: state)
        
        cell.onToggleExpand = { [weak self, weak tableView] in
            guard let self, let tableView else { return }
            self.viewModel?.toggleExpansion(at: indexPath)
            
            UIView.performWithoutAnimation {
                let offset = tableView.contentOffset
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.beginUpdates()
                tableView.endUpdates()
                tableView.setContentOffset(offset, animated: false)
            }
        }
        return cell
    }
}

// MARK: - Delegate

extension NotificationFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NotificationSectionHeaderView()
        header.configure(date: renderedSections[section].date)
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
            contentView.tableView.setContentOffset(.zero, animated: true)
        }
    }
}

extension NotificationFeedViewController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        triggerRefresh()
    }
}

extension NotificationFeedViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let targetVC = (viewController as? UINavigationController)?.viewControllers.first ?? viewController
        
        if targetVC === self {
            if tabBarController.selectedViewController === viewController {
                self.scrollToTop()
            }
        }
        return true
    }
}
