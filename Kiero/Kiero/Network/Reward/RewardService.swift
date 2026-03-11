//
//  RewardService.swift
//  Kiero
//
//  Created by 정윤아 on 3/7/26.
//

import Combine
import Foundation

protocol RewardServiceType {
    func fetchCoupons(childId: Int) -> AnyPublisher<[Reward], NetworkError>
    func addCoupon(childId: Int, title: String, cost: Int) -> AnyPublisher<Void, NetworkError>
    func deleteCoupon(couponId: Int) -> AnyPublisher<Void, NetworkError>
    func updateCoupon(couponId: Int, title: String, cost: Int) -> AnyPublisher<Void, NetworkError>
}

final class RewardService: RewardServiceType {
    static let shared = RewardService()
    
    private init() {}
    
    func fetchCoupons(childId: Int) -> AnyPublisher<[Reward], NetworkError> {
        return Future<[Reward], NetworkError> { promise in
            Task {
                do {
                    let response: [RewardResponseDTO] = try await BaseService.shared.request(endPoint: .fetchCoupons(childId: childId))
                    promise(.success(response.map{ $0.toEntity() }))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addCoupon(childId: Int, title: String, cost: Int) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let requestBody = RewardCreateRequestDTO(name: title, price: cost)
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: .addCoupon(childId: childId),
                        body: requestBody
                    )
                    
                    promise(.success(()))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteCoupon(couponId: Int) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let _: EmptyResponse = try await BaseService.shared.request(endPoint: .deleteCoupon(couponId: couponId))
                    
                    promise(.success(()))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateCoupon(couponId: Int, title: String, cost: Int) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let requestBody = RewardCreateRequestDTO(name: title, price: cost)
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: .updateCoupon(couponId: couponId),
                        body: requestBody
                    )
                    
                    promise(.success(()))
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
