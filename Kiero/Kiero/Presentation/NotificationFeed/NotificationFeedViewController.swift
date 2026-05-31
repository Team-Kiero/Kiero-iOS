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
    private var lastItemCount = 0
    
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
        
        NotificationCenter.default.publisher(for: .deepLinkReceived)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self,
                      let targetId = DeepLinkManager.shared.pendingTargetId else { return }
                
                self.deepLinkTargetId = targetId
                self.processDeepLinkIfNeeded()
            }
            .store(in: &cancellables)
        
        
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
                
                DispatchQueue.main.async {
                    let tableHeight = self.contentView.tableView.frame.height
                    let bottomInset = max(0, tableHeight - 100)
                    self.contentView.tableView.contentInset.bottom = bottomInset
                }
                
                self.processDeepLinkIfNeeded()
            }
            .store(in: &cancellables)
        
        viewDidLoadSubject.send(())
    }
    
    @discardableResult
    private func scrollToFeedAndExpand(targetId: Int64) -> Bool {
        for (sectionIndex, section) in renderedSections.enumerated() {
            for (rowIndex, item) in section.items.enumerated() {
                guard item.feedId == targetId else { continue }

                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)

                if case .finishSchedule = item {
                    self.viewModel?.toggleExpansion(at: indexPath)
                }

                UIView.performWithoutAnimation {
                    self.contentView.tableView.reloadRows(at: [indexPath], with: .none)
                    self.contentView.tableView.beginUpdates()
                    self.contentView.tableView.endUpdates()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.contentView.tableView.scrollToRow(
                        at: indexPath,
                        at: .top,
                        animated: true
                    )
                }
                return true
            }
        }
        return false
    }
    
    private func processDeepLinkIfNeeded() {
        guard let targetId = self.deepLinkTargetId,
              !self.renderedSections.isEmpty,
              self.renderedSections.contains(where: { !$0.items.isEmpty }) else { return }
        
        let currentAllItemsCount = self.renderedSections.flatMap { $0.items }.count
        let isFound = self.scrollToFeedAndExpand(targetId: targetId)
        
        if isFound {
            self.deepLinkTargetId = nil
            self.lastItemCount = 0
            DeepLinkManager.shared.clear()
            print("🎯 [DeepLink] 타겟 알림을 찾아 스크롤했습니다.")
        } else {
            let viewModelCanLoadMore = self.viewModel?.canLoadMore ?? false
            let isDataNotGrowing = (currentAllItemsCount == self.lastItemCount)
            
            if !viewModelCanLoadMore || isDataNotGrowing {
                print("⚠️ [DeepLink] 모든 페이지를 탐색했으나 타겟 알림(ID: \(targetId))을 찾지 못했습니다.")
                self.deepLinkTargetId = nil
                self.lastItemCount = 0
                DeepLinkManager.shared.clear()
            } else {
                self.lastItemCount = currentAllItemsCount
                self.loadMoreSubject.send(())
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
