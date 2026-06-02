//
//  ChildTermsService.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/27/26.
//

import Combine
import Foundation

final class ChildTermsService {
    static let shared = ChildTermsService()
    private init() {}
    
    func fetchTerms() -> AnyPublisher<[ChildTermsDTO], NetworkError> {
        return Future<[ChildTermsDTO], NetworkError> { promise in
            Task {
                do {
                    let dtos: [ChildTermsDTO] = try await BaseService.shared.request(endPoint: .fetchChildTerms)
                    promise(.success(dtos))
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
