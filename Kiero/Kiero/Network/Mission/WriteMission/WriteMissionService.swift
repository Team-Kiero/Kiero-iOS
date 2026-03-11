//
//  WriteMissionService.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation
import Combine

protocol WriteMissionServiceType {
    func postMission(childId: Int, request: WriteMissionRequestDTO) -> AnyPublisher<WriteMissionResponseDTO, NetworkError>
    func updateMission(missionId: Int, request: WriteMissionRequestDTO) -> AnyPublisher<WriteMissionResponseDTO, NetworkError>
}

final class WriteMissionService: WriteMissionServiceType {
    func postMission(childId: Int, request: WriteMissionRequestDTO) -> AnyPublisher<WriteMissionResponseDTO, NetworkError> {
        let endPoint = EndPoint.postMission(childId: childId, request: request)
        
        return Future<WriteMissionResponseDTO, NetworkError> { promise in
            Task {
                do {
                    let response: WriteMissionResponseDTO = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: request
                    )
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
    
    func updateMission(missionId: Int, request: WriteMissionRequestDTO) -> AnyPublisher<WriteMissionResponseDTO, NetworkError> {
        let endPoint = EndPoint.updateMission(missionId: missionId, request: request)
        
        return Future<WriteMissionResponseDTO, NetworkError> { promise in
            Task {
                do {
                    let response: WriteMissionResponseDTO = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: request
                    )
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
