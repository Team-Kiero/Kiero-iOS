//
//  WishWellViewController.swift
//  Kiero
//
//  Created by 정윤아 on 1/12/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class WishWellViewController: BaseViewController<WishWellViewModel>{
    
    // MARK: - Properties
    
    private let rootView = WishWellView()
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    private let purchaseConfirmedSubject = PassthroughSubject<Int64, Never>()
    
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let viewWillDisappearSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Life Cycle
    
    override func loadView() { view = rootView }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshSubject.send(())
        viewWillAppearSubject.send(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearSubject.send(())
    }
    
    // MARK: - Setup Methods
    
    override func setDelegate() {
        rootView.wishCollectionView.dataSource = self
        rootView.wishCollectionView.delegate = self
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: WishWellViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = WishWellViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            refresh: refreshSubject.eraseToAnyPublisher(),
            purchaseConfirmed: purchaseConfirmedSubject.eraseToAnyPublisher(),
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            viewWillDisappear: viewWillDisappearSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.userInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] info in
                self?.rootView.configureUserInfo(name: info.name, price: info.coin)
            }
            .store(in: &cancellables)
        
        output.coupons
            .receive(on: RunLoop.main)
            .sink { [weak self] coupons in
                guard let self = self else { return }
                
                self.rootView.updateEmptyState(isEmpty: coupons.isEmpty)
                self.rootView.wishCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewDidLoadSubject.send(())
    }
}

// MARK: - DataSource

extension WishWellViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.coupons.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WishWellCell.identifier, for: indexPath) as? WishWellCell,
              let data = viewModel?.coupons[indexPath.item] else {
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
        let data = vm.coupons[indexPath.item]
        
        if vm.currentCoinCount < data.price {
            Toast.show(message: "금화가 부족해! 미션을 더 하고 오자!", bottomInset: 117)
            return
        }
        let dialogState = DialogBox.State.wishWell(title: data.name, coin: "\(data.price)")
        
        view.showDialog(state: dialogState) { [weak self] in
            self?.showPurchaseConfirm(for: data)
        }
    }
    
    func showPurchaseConfirm(for coupon: Coupon) {
        let confirmState = ConfirmBox.State.wishWell(wish: coupon.name)
        
        view.showConfirm(state: confirmState) { [weak self] in
            self?.purchaseConfirmedSubject.send(coupon.id)
        }
    }
}

extension WishWellViewController: ScrollToTopAvailable {
    func scrollToTop() {
        rootView.wishCollectionView.setContentOffset(.zero, animated: true)
    }
}

extension WishWellViewController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        refreshSubject.send(())
    }
}
