//
//  AddScheduleService.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation
import Combine

protocol AddScheduleServiceType {
    func postSchedule(childId: Int, request: AddScheduleRequestDTO) -> AnyPublisher<Bool, NetworkError>
}

final class AddScheduleService: AddScheduleServiceType {
    func postSchedule(childId: Int, request: AddScheduleRequestDTO) -> AnyPublisher<Bool, NetworkError> {
        let endPoint = EndPoint.postSchedule(childId: childId, request: request)
        
        return Future<Bool, NetworkError> { promise in
            Task {
                do {
                    let _: AddScheduleResponseDTO = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: request
                    )
                    promise(.success(true))
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
