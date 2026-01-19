//
//  CoinMissionViewController.swift
//  Kiero
//
//  Created by 정윤아 on 1/13/26.
//

import UIKit
import Combine

final class CoinMissionViewController: BaseViewController<CoinMissionViewModel> {
    
    // MARK: - Properties
    
    private let rootView = CoinMissionView()
    private var dataSource: [DailyMissionData] = []
    
    // MARK: - Life Cycle
    
    override func loadView() { view = rootView }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        if let vm = viewModel {
            rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
        }
    }
    
    override func setDelegate() {
        rootView.missionCollectionView.delegate = self
        rootView.missionCollectionView.dataSource = self
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: CoinMissionViewModel) {
        let input = CoinMissionViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        output.missionData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                
                self.dataSource = data
                let isEmpty = data.isEmpty
                self.rootView.updateEmptyState(isEmpty: isEmpty)
                if !isEmpty {
                    self.rootView.missionCollectionView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - DataSource

extension CoinMissionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DailyMissionCell.identifier,
            for: indexPath
        ) as? DailyMissionCell else { return UICollectionViewCell() }
        
        let data = dataSource[indexPath.item]
        cell.configure(
            date: data.date,
            missions: data.missions
        )
        cell.missionTapHandler = { [weak self] id, name in
            self?.handleMissionTap(id: id, name: name)
        }
        return cell
    }
}

// MARK: - Delegate

extension CoinMissionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 31)
        return CGSize(width: width, height: 10)
    }
}

// MARK: - Action

private extension CoinMissionViewController {
    func handleMissionTap(id: Int64, name: String) {
        let dialogState = DialogBox.State.missionComplete(title: name)
        view.showDialog(state: dialogState) { [weak self] in
            guard let self = self else { return }
            
            var rewardAmount = 0
            for data in self.dataSource {
                if let mission = data.missions.first(where: { $0.id == id }) {
                    rewardAmount = mission.reward
                    break
                }
            }
            self.view.showConfirm(state: .coinMission(count: rewardAmount)) {
                self.completeMissionDirectly(id: id, reward: rewardAmount)
            }
        }
    }
    
    private func completeMissionDirectly(id: Int64, reward: Int) {
        viewModel?.getCoin(reward: reward)
        
        for (sectionIndex, dayDate) in dataSource.enumerated() {
            if let missionIndex = dayDate.missions.firstIndex(where: {$0.id == id}) {
                var updatedMissions = dayDate.missions
                updatedMissions[missionIndex].isCompleted = true
                
                dataSource[sectionIndex] = DailyMissionData(
                    date: dayDate.date,
                    missions: updatedMissions
                )
                break
            }
        }
        
        if let vm = viewModel {
            rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
        }
        rootView.missionCollectionView.reloadData()
        // TODO: 서버에게 변경된 금화, 상태 데이터 전송
    }
}

extension CoinMissionViewController: ScrollToTopAvailable {
    func scrollToTop() {
        let collectionView = rootView.missionCollectionView
        if collectionView.numberOfSections > 0 && collectionView.numberOfItems(inSection: 0) > 0 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        } else {
            collectionView.setContentOffset(.zero, animated: true)
        }
    }
}
