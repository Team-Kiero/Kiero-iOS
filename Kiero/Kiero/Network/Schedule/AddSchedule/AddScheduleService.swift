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
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: request
                    )
                    
                    print("✅ [Service] 일정 생성 성공 (EmptyResponse 처리 완료)")
                    promise(.success(true))
                    
                } catch let error as NetworkError {
                    print("❌ [Service] 네트워크 에러: \(error.errorDescription)")
                    promise(.failure(error))
                } catch {
                    print("❌ [Service] 알 수 없는 에러: \(error)")
                    promise(.failure(.responseDecodingError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
