//
//  WishWellViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 1/12/26.
//

import Combine
import Foundation

final class WishWellViewModel: BaseViewModel, ViewModelType {
    
    private let service: WishWellServiceType
    
    private var userInfoSubject = CurrentValueSubject<ChildrenInfo?, Never>(nil)
    private var couponsSubject = CurrentValueSubject<[Coupon], Never>([])
    private var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private var errorMessageSubject = PassthroughSubject<String, Never>()
    private var purchaseCompletedSubject = PassthroughSubject<Coupon, Never>()
    
    var currentCoinCount: Int { userInfoSubject.value?.coinAmount ?? 0 }
    var userName: String { userInfoSubject.value?.firstName ?? "" }
    var coupons: [Coupon] { couponsSubject.value }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let refresh: AnyPublisher<Void, Never>
        let purchaseConfirmed: AnyPublisher<Int64, Never> // couponId
    }
    
    struct Output {
        let userInfo: AnyPublisher<(name: String, coin: Int, today: String), Never>
        let coupons: AnyPublisher<[Coupon], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<String, Never>
        let purchaseCompleted: AnyPublisher<Coupon, Never>
    }
    
    // MARK: - Init
    
    init(service: WishWellServiceType) {
        self.service = service
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let loadTrigger = Publishers.Merge(input.viewDidLoad, input.refresh)
            .eraseToAnyPublisher()
        
        loadTrigger
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
            })
            .flatMap{ [weak self] _ -> AnyPublisher<(ChildrenInfo, [Coupon]), Never> in
                guard let self = self else {
                    return Just((ChildrenInfo(firstName: "", coinAmount: 0, today: ""), []))
                        .eraseToAnyPublisher()
                }
                
                let me = self.service.fetchMyInfo()
                    .catch { [weak self] err -> Just<ChildrenInfo> in
                        self?.errorMessageSubject.send(err.errorDescription)
                        return Just(ChildrenInfo(firstName: "", coinAmount: 0, today: ""))
                    }
                
                let coupons = self.service.fetchCoupons()
                    .catch { [weak self] err -> Just<[Coupon]> in
                        self?.errorMessageSubject.send(err.errorDescription)
                        return Just([])
                    }
                
                return Publishers.Zip(me, coupons).eraseToAnyPublisher()
            }
            .sink { [weak self] me, coupons in
                guard let self = self else { return }
                self.userInfoSubject.send(me)
                self.couponsSubject.send(coupons)
                self.isLoadingSubject.send(false)
            }
            .store(in: &cancellables)
        
        input.purchaseConfirmed
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
            })
            .flatMap { [weak self] couponId -> AnyPublisher<Coupon, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher()}
                return self.service.purchaseCoupon(couponId: couponId)
                    .handleEvents(receiveOutput: { [weak self] purchased in
                        self?.purchaseCompletedSubject.send(purchased)
                    })
                    .catch { [weak self] err -> Empty<Coupon, Never> in
                        self?.errorMessageSubject.send(err.errorDescription)
                        self?.isLoadingSubject.send(false)
                        return .init()
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] _ -> AnyPublisher<(ChildrenInfo, [Coupon]), Never> in
                guard let self = self else {
                    return Just((ChildrenInfo(firstName: "", coinAmount: 0, today: ""), []))
                        .eraseToAnyPublisher()
                }
                
                let me = self.service.fetchMyInfo()
                    .catch { [weak self] err -> Just<ChildrenInfo> in
                        self?.errorMessageSubject.send(err.errorDescription)
                        return Just(ChildrenInfo(firstName: "", coinAmount: 0, today: ""))
                    }
                
                let coupons = self.service.fetchCoupons()
                    .catch { [weak self] err -> Just<[Coupon]> in
                        self?.errorMessageSubject.send(err.errorDescription)
                        return Just([])
                    }
                
                return Publishers.Zip(me, coupons).eraseToAnyPublisher()
            }
            .sink { [weak self] me, coupons in
                guard let self = self else { return }
                self.userInfoSubject.send(me)
                self.couponsSubject.send(coupons)
                self.isLoadingSubject.send(false)
            }
            .store(in: &cancellables)
        
        let userInfo = userInfoSubject
            .compactMap { $0 }
            .map { (name: $0.firstName, coin: $0.coinAmount, today: $0.today) }
            .eraseToAnyPublisher()
        
        return Output(
            userInfo: userInfo,
            coupons: couponsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            purchaseCompleted: purchaseCompletedSubject.eraseToAnyPublisher()
        )
    }
}
