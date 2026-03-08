//
//  ScheduleService.swift
//  Kiero
//
//  Created by 신혜연 on 1/20/26.
//

import Foundation
import Combine

protocol ScheduleServiceType {
    func fetchChildren() -> AnyPublisher<[ChildResponseDTO], NetworkError>
    func fetchSchedules(childId: Int, startDate: Date, endDate: Date) -> AnyPublisher<(isFireLit: Bool, schedules: [Schedule]), NetworkError>
    func deleteChildDummyData() -> AnyPublisher<Void, NetworkError>
    func logout() -> AnyPublisher<Void, NetworkError>
    func deleteSchedule(scheduleId: Int, selectedDate: String, isIncludeFollowing: Bool) -> AnyPublisher<Void, NetworkError>
    func editSchedule(scheduleId: Int, selectedDate: String, request: EditScheduleRequestDTO) -> AnyPublisher<Void, NetworkError>
}

final class ScheduleService: ScheduleServiceType {
    static let shared = ScheduleService()
    
    func fetchChildren() -> AnyPublisher<[ChildResponseDTO], NetworkError> {
        let endPoint = EndPoint.fetchChildren
        return Future<[ChildResponseDTO], NetworkError> { promise in
            Task {
                do {
                    let response: [ChildResponseDTO] = try await BaseService.shared.request(endPoint: endPoint)
                    promise(.success(response))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchSchedules(childId: Int, startDate: Date, endDate: Date) -> AnyPublisher<(isFireLit: Bool, schedules: [Schedule]), NetworkError> {
        let startStr = startDate.toString(format: "yyyy-MM-dd")
        let endStr = endDate.toString(format: "yyyy-MM-dd")
        let endPoint = EndPoint.fetchSchedules(childId: childId, startDate: startStr, endDate: endStr)
        
        return Future<(isFireLit: Bool, schedules: [Schedule]), NetworkError> { promise in
            Task {
                do {
                    let response: ScheduleResponseDTO = try await BaseService.shared.request(endPoint: endPoint)
                    promise(.success((isFireLit: response.isFireLit, schedules: response.toEntity())))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteChildDummyData() -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let _: EmptyResponse = try await BaseService.shared.request(endPoint: .deleteChildDummy)
                    promise(.success(()))
                } catch {
                    promise(.failure(error as? NetworkError ?? .unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let _: EmptyResponse = try await BaseService.shared.request(endPoint: .logout)
                    promise(.success(()))
                } catch {
                    promise(.failure(error as? NetworkError ?? .unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteSchedule(scheduleId: Int, selectedDate: String, isIncludeFollowing: Bool) -> AnyPublisher<Void, NetworkError> {
        let endPoint = EndPoint.deleteSchedule(
            scheduleId: scheduleId,
            selectedDate: selectedDate
        )
        let requestBody = DeleteScheduleRequestDTO(isIncludeFollowing: isIncludeFollowing)
        
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: endPoint,
                        body: requestBody
                    )
                    promise(.success(()))
                } catch {
                    promise(.failure(error as? NetworkError ?? .unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func editSchedule(scheduleId: Int, selectedDate: String, request: EditScheduleRequestDTO) -> AnyPublisher<Void, NetworkError> {
        let endPoint = EndPoint.editSchedule(scheduleId: scheduleId, selectedDate: selectedDate)
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    let _: EmptyResponse = try await BaseService.shared.request(endPoint: endPoint, body: request)
                    promise(.success(()))
                } catch {
                    promise(.failure(error as? NetworkError ?? .unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
}
