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
}

final class AIMissionService: AIMissionServiceType {
    func postMissionSuggestions(text: String) -> AnyPublisher<[SuggestedMissionDTO], NetworkError> {
        let requestDTO = MissionSuggestionRequestDTO(noticeText: text)
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
}
