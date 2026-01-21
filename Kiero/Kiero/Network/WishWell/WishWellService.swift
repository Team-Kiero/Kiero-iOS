//
//  WishWellService.swift
//  Kiero
//
//  Created by 정윤아 on 1/20/26.
//

import Combine
import Foundation

protocol WishWellServiceType {
    func fetchMyInfo() -> AnyPublisher<ChildrenInfo, NetworkError>
    func fetchCoupons() -> AnyPublisher<[Coupon], NetworkError>
    func purchaseCoupon(couponId: Int64) ->  AnyPublisher<Coupon, NetworkError>
}

final class WishWellService: WishWellServiceType {
    
    func fetchMyInfo() -> AnyPublisher<ChildrenInfo, NetworkError> {
        let endpoint = EndPoint.fetchChildrenInfo
        
        return Future<ChildrenInfo, NetworkError> { promise in
            Task {
                do {
                    let dto: ChildrenInfoResponseDTO = try await BaseService.shared.request(endPoint: endpoint)
                    promise(.success(dto.toEntity()))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCoupons() -> AnyPublisher<[Coupon], NetworkError> {
        let endpoint = EndPoint.fetchWishes
        
        return Future<[Coupon], NetworkError> { promise in
            Task {
                do {
                    let dtos: [CouponResponseDTO] = try await BaseService.shared.request(endPoint: endpoint)
                    promise(.success(dtos.map{ $0.toEntity() }))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func purchaseCoupon(couponId: Int64) -> AnyPublisher<Coupon, NetworkError> {
        let endpoint = EndPoint.purchaseCoupon(couponId: couponId)
        
        return Future<Coupon, NetworkError> { promise in
            Task {
                do {
                    let dto: CouponResponseDTO = try await BaseService.shared.request(endPoint: endpoint)
                    promise(.success(dto.toEntity()))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
