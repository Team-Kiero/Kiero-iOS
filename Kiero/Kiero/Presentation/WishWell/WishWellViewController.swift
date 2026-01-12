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
        cell.onTapComplete = { [weak self] in
            guard let self = self,
                    let data = viewModel?.wishList[indexPath.item] else { return }
            let dialogState = DialogBox.State.wishWell(title: data.name, coin: "\(data.price)")
            
            self.view.showDialog(state: dialogState) { [weak self] in
                let confirmState = ConfirmBox.State.wishWell(wish: data.name)
                self?.view.showConfirm(state: confirmState) { [weak self] in
                    guard let self = self,
                            let vm = self.viewModel else { return }
                    
                    vm.purchaseCoin(price: data.price)
                    
                    self.rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
                }
                
            }
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
