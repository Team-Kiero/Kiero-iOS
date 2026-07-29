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
    
    private var sseStarted = false
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let refresh: AnyPublisher<Void, Never>
        let purchaseConfirmed: AnyPublisher<Int64, Never>
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewWillDisappear: AnyPublisher<Void, Never>
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
            .sink { [weak self] _ in
                self?.fetchInitialData()
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
                        AmplitudeManager.shared.track(.wishPurchased, properties: [
                            AnalyticsEventProperty.price: purchased.price
                        ])
                        self?.purchaseCompletedSubject.send(purchased)
                    })
                    .catch { [weak self] err -> Empty<Coupon, Never> in
                        self?.errorMessageSubject.send(err.errorDescription)
                        self?.isLoadingSubject.send(false)
                        return .init()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] _ in
                self?.fetchInitialData()
            }
            .store(in: &cancellables)
        
        input.viewWillAppear
            .sink { [weak self] _ in
                self?.startSSEIfNeeded()
            }
            .store(in: &cancellables)
        
        input.viewWillDisappear
            .sink { [weak self] _ in
                self?.stopSSE()
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
    
    private func fetchInitialData() {
        isLoadingSubject.send(true)
        
        let me = self.service.fetchMyInfo()
            .catch { [weak self] err -> Just<ChildrenInfo> in
                self?.errorMessageSubject.send(err.errorDescription)
                return Just(ChildrenInfo(firstName: "", coinAmount: 0, today: "", pushNotificationEnabled: false))
            }
        
        let coupons = self.service.fetchCoupons()
            .catch { [weak self] err -> Just<[Coupon]> in
                self?.errorMessageSubject.send(err.errorDescription)
                return Just([])
            }
        
        Publishers.Zip(me, coupons)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] meData, couponsData in
                self?.userInfoSubject.send(meData)
                self?.couponsSubject.send(couponsData)
                self?.isLoadingSubject.send(false)
            }
            .store(in: &cancellables)
    }
    
    private func refetchCoupons() {
        fetchInitialData()
    }
    
    // MARK: - SSE Connection
    
    private func startSSEIfNeeded() {
        guard !sseStarted else { return }
        sseStarted = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let initialToken = try await TokenRefresher.shared.reissueSseAccessToken()
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    
                    SseStreamManager.shared.startIfNeeded(initialToken: initialToken) { [weak self] payload in
                        self?.handleCouponSse(payload: payload)
                    }
                    print("✅ [WishWellVM] SSE started")
                }
            } catch {
                print("❌ [WishWellVM] SSE token reissue failed:", error)
                self.sseStarted = false
            }
        }
    }
    
    private func stopSSE() {
        SseStreamManager.shared.stop()
        sseStarted = false
        print("🛑 [WishWellVM] SSE stopped")
    }
    
    private func handleCouponSse(payload: SseEventPayload) {
        guard payload.eventType == "COUPON_CREATED" else { return }
        
        print("🔔 [WishWellVM] COUPON_CREATED 이벤트 수신! 데이터 재조회 시작...")
        
        refetchCoupons()
    }
}
