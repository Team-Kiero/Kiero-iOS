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
    
    override func loadView() {
        view = rootView
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        if let vm = viewModel {
            rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
        }
    }
    
    override func bind(viewModel: CoinMissionViewModel) {
        let input = CoinMissionViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        output.missionData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.dataSource = data
                self?.rootView.missionCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    override func setDelegate() {
        rootView.missionCollectionView.delegate = self
        rootView.missionCollectionView.dataSource = self
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
        cell.configure(date: data.date, missions: data.missions)
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
