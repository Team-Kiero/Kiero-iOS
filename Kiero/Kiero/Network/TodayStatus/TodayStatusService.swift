//
//  TodayStatusService.swift
//  Kiero
//
//  Created by 안치욱 on 3/12/26.
//

import Combine
import Foundation

protocol TodayStatusServiceType {
    func fetchTodayStatus(childId: Int) -> AnyPublisher<TodayStatusDTO, NetworkError>
    func postScheduleImage(scheduleDetailId: Int) -> AnyPublisher<ScheduleImageDTO, NetworkError>
}

final class TodayStatusService: TodayStatusServiceType {
    
    static let shared = TodayStatusService()
    
    private init() {}
    
    func fetchTodayStatus(childId: Int) -> AnyPublisher<TodayStatusDTO, NetworkError> {
        return Future<TodayStatusDTO, NetworkError> { promise in
            Task {
                do {
                    let response: TodayStatusDTO = try await BaseService.shared.request(
                        endPoint: .fetchTodayStatus(childId: childId)
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
    
    func postScheduleImage(scheduleDetailId: Int) -> AnyPublisher<ScheduleImageDTO, NetworkError> {
        return Future<ScheduleImageDTO, NetworkError> { promise in
            Task {
                do {
                    let response: ScheduleImageDTO = try await BaseService.shared.request(
                        endPoint: .postImageRead(scheduleDetailId: scheduleDetailId)
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
