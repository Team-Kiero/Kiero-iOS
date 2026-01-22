//
//  CoinMissionService.swift
//  Kiero
//
//  Created by 정윤아 on 1/22/26.
//

import Combine
import Foundation

protocol CoinMissionServiceType {
    func completeMission(missionId: Int64) -> AnyPublisher<MissionCompleteResponseDTO, NetworkError>
}

final class CoinMissionService: CoinMissionServiceType {
    func completeMission(missionId: Int64) -> AnyPublisher<MissionCompleteResponseDTO, NetworkError> {
        let endpoint = EndPoint.completeMission(missionId: missionId)
        
        return Future { promise in
            Task {
                do {
                    let dto: MissionCompleteResponseDTO = try await BaseService.shared.request(endPoint: endpoint)
                    promise(.success(dto))
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
