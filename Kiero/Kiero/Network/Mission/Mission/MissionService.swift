//
//  MissionService.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation
import Combine

protocol MissionServiceType {
    func fetchMissions(childId: Int?) -> AnyPublisher<MissionListResponseDTO, NetworkError>
}

final class MissionService: MissionServiceType {
    func fetchMissions(childId: Int?) -> AnyPublisher<MissionListResponseDTO, NetworkError> {
        let endPoint = EndPoint.fetchMissions(childId: childId)
        
        return Future<MissionListResponseDTO, NetworkError> { promise in
            Task {
                do {
                    let response: MissionListResponseDTO = try await BaseService.shared.request(endPoint: endPoint)
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
