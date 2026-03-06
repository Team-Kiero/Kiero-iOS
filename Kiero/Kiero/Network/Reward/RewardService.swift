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
}
