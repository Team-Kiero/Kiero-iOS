//
//  NotificationFeedService.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Combine
import Foundation

protocol FeedServiceType {
    func fetchFeeds(childId: Int64, size: Int?, cursor: String?) -> AnyPublisher<FeedPage, NetworkError>
    func fetchUnreadFeed() -> AnyPublisher<UnreadNotificationDTO, NetworkError>
}

final class FeedService: FeedServiceType {
    func fetchFeeds(childId: Int64, size: Int? = 20, cursor: String? = nil) -> AnyPublisher<FeedPage, NetworkError> {
        let endPoint = EndPoint.fetchFeeds(childId: childId, size: size, cursor: cursor)
        
        return Future<FeedPage, NetworkError> { promise in
            Task {
                do {
                    let dto: FeedResponseDTO = try await BaseService.shared.request(endPoint: endPoint)
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
    
    func fetchUnreadFeed() -> AnyPublisher<UnreadNotificationDTO, NetworkError> {
        let endPoint = EndPoint.fetchUnreadFeed
        
        return Future<UnreadNotificationDTO, NetworkError> { promise in
            Task {
                do {
                    let response: UnreadNotificationDTO = try await BaseService.shared.request(endPoint: endPoint)
                    promise(.success(response))
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
