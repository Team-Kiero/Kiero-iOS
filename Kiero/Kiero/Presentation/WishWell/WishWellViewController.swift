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
    
    // MARK: - Properties
    
    private let rootView = WishWellView()
    
    // MARK: - Life Cycle
    
    override func loadView() { view = rootView }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        if let vm = viewModel {
            rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
        }
    }
    
    override func setDelegate() {
        rootView.wishCollectionView.dataSource = self
        rootView.wishCollectionView.delegate = self
    }
    
    // MARK: - Bind
    
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
            self?.handleWishSelection(at: indexPath)
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

// MARK: - Action

private extension WishWellViewController {
    func handleWishSelection(at indexPath: IndexPath) {
        guard let vm = viewModel else { return }
        let data = vm.wishList[indexPath.item]
        
        if vm.currentCoinCount < data.price {
            Toast.show(message: "금화가 부족해! 미션을 더 하고 오자!")
            return
        }
        let dialogState = DialogBox.State.wishWell(title: data.name, coin: "\(data.price)")
        
        view.showDialog(state: dialogState) { [weak self] in
            self?.showPurchaseConfirm(for: data)
        }
    }
    
    func showPurchaseConfirm(for wish: Wish) {
        let confirmState = ConfirmBox.State.wishWell(wish: wish.name)
        
        view.showConfirm(state: confirmState) { [weak self] in
            guard let self = self,
                  let vm = self.viewModel else { return }
            
            vm.purchaseCoin(price: wish.price)
            self.rootView.configureUserInfo(name: vm.userName, price: vm.currentCoinCount)
            
            // TODO: 서버에게 변경된 금화 데이터 전송
        }
    }
}
