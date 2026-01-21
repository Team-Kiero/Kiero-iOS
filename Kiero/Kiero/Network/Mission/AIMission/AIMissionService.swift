//
//  AIMissionService.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation
import Combine

protocol AIMissionServiceType {
    func postMissionSuggestions(text: String) -> AnyPublisher<[SuggestedMissionDTO], NetworkError>
    func postBulkMissions(childId: Int, missions: [MissionBulkItemDTO]) -> AnyPublisher<[MissionBulkCreateResponseDTO], NetworkError>
}

final class AIMissionService: AIMissionServiceType {
    func postMissionSuggestions(text: String) -> AnyPublisher<[SuggestedMissionDTO], NetworkError> {
        let escapedText = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        
        let requestDTO = MissionSuggestionRequestDTO(noticeText: escapedText)
        let endPoint = EndPoint.postMissionSuggestions(request: requestDTO)
        
        return Future<[SuggestedMissionDTO], NetworkError> { promise in
            Task {
                do {
                    let response: MissionSuggestionResponseDTO = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: requestDTO
                    )
                    
                    promise(.success(response.suggestedMissions))
                    
                } catch {
                    print("❌ [Service] 알림장 분석 에러 상세: \(error)")
                    promise(.failure(.responseDecodingError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func postBulkMissions(childId: Int, missions: [MissionBulkItemDTO]) -> AnyPublisher<[MissionBulkCreateResponseDTO], NetworkError> {
        let requestDTO = MissionBulkCreateRequestDTO(missions: missions)
        let endPoint = EndPoint.postBulkMissions(childId: childId, request: requestDTO)
        
        return Future<[MissionBulkCreateResponseDTO], NetworkError> { promise in
            Task {
                do {
                    let response: [MissionBulkCreateResponseDTO] = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: requestDTO
                    )
                    promise(.success(response))
                } catch {
                    print("❌ [Service] 미션 일괄 생성 에러: \(error)")
                    promise(.failure(.responseDecodingError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
