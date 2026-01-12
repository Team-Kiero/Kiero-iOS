//
//  WishWellViewController.swift
//  Kiero
//
//  Created by 정윤아 on 1/12/26.
//
import UIKit

import SnapKit
import Then

final class WishWellViewController: BaseViewController<WishWellViewModel>{
    
    private let rootView = WishWellView()
    
    override func loadView() { view = rootView }
    
    override func setUI() {
        if let vm = viewModel {
            rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
        }
    }
    
    override func setDelegate() {
        rootView.wishCollectionView.dataSource = self
        rootView.wishCollectionView.delegate = self
    }
    
    override func bind(viewModel: WishWellViewModel) {
        super.bind(viewModel: viewModel)
        
        viewModel.fetchWishList { [weak self] in
            DispatchQueue.main.async {
                self?.rootView.wishCollectionView.reloadData()
            }
        }
    }
}


// MARK: - DataSource

extension WishWellViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.wishList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WishWellCell.identifier, for: indexPath) as? WishWellCell,
              let data = viewModel?.wishList[indexPath.item] else {
            return UICollectionViewCell()
        }
        cell.configure(name: data.name, price: data.price)
        
        cell.onTapComplete = {
            print("\(data.name) 구매 버튼 클릭됨")
        }
        
        return cell
    }
}

// MARK: - Delegate

extension WishWellViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (16 * 2) - 13) / 2
        return CGSize(width: width, height: 113)
    }
}

#Preview {
    WishWellViewController(
        viewModel: WishWellViewModel(),
        diContainer: AppDIContainer.shared
    )
}
