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
    private var dataSource: [MissionGroupDTO] = []
    
    private let completeMissionSubject = PassthroughSubject<Int64, Never>()
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Life Cycle
    
    override func loadView() { view = rootView }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.send(())
    }
    
    // MARK: - Setup Methods
    
    override func setDelegate() {
        rootView.missionCollectionView.delegate = self
        rootView.missionCollectionView.dataSource = self
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: CoinMissionViewModel) {
        let input = CoinMissionViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            completeMission: completeMissionSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.userInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] info in
                self?.rootView.configureUserInfo(name: info.firstName, price: info.coinAmount)
            }
            .store(in: &cancellables)
        
        output.missions
            .receive(on: RunLoop.main)
            .sink { [weak self] groups in
                guard let self else { return }
                
                self.dataSource = groups
                let isEmpty = groups.isEmpty
                self.rootView.updateEmptyState(isEmpty: isEmpty)
                self.rootView.missionCollectionView.reloadData()
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
        
        let group = dataSource[indexPath.item]
        
        cell.configure(
            dueAt: group.dueAt,
            dayOfWeek: group.dayOfWeek,
            missions: group.missions
        )
        
        cell.missionTapHandler = { [weak self] missionId, name in
            self?.handleMissionTap(id: missionId, name: name)
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
            
            let rewardAmount = self.findRewardAmount(missionId: id)
            self.view.showConfirm(state: .coinMission(count: rewardAmount)) {
                self.completeMissionSubject.send(id)
            }
        }
    }
    
    func findRewardAmount(missionId: Int64) -> Int {
        let targetId = Int(missionId) // MissionItemDTO.id가 Int
        
        for group in dataSource {
            if let mission = group.missions.first(where: { $0.id == targetId }) {
                return mission.reward
            }
        }
        return 0
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

extension CoinMissionViewController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        viewWillAppearSubject.send(())
    }
}
