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
    func fetchSchedules(childId: Int, startDate: Date, endDate: Date) -> AnyPublisher<[Schedule], NetworkError>
    func deleteChildDummyData() -> AnyPublisher<Void, NetworkError>
    func logout() -> AnyPublisher<Void, NetworkError>
}

final class ScheduleService: ScheduleServiceType {
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
    
    func fetchSchedules(childId: Int, startDate: Date, endDate: Date) -> AnyPublisher<[Schedule], NetworkError> {
        let startStr = startDate.toString(format: "yyyy-MM-dd")
        let endStr = endDate.toString(format: "yyyy-MM-dd")
        let endPoint = EndPoint.fetchSchedules(childId: childId, startDate: startStr, endDate: endStr)
        
        return Future<[Schedule], NetworkError> { promise in
            Task {
                do {
                    let response: ScheduleResponseDTO = try await BaseService.shared.request(endPoint: endPoint)
                    promise(.success(response.toEntity()))
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
}
