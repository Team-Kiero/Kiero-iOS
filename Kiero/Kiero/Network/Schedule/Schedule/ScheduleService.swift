//
//  ScheduleService.swift
//  Kiero
//
//  Created by 신혜연 on 1/20/26.
//

import Combine
import Foundation

protocol ScheduleServiceType {
    func fetchChildren() -> AnyPublisher<[ChildResponseDTO], NetworkError>
    func fetchSchedules(
        childId: Int,
        startDate: Date,
        endDate: Date
    ) -> AnyPublisher<(isFireLit: Bool, schedules: [Schedule]), NetworkError>
    func deleteChildDummyData() -> AnyPublisher<Void, NetworkError>
    func logout() -> AnyPublisher<Void, NetworkError>
}

final class ScheduleService: ScheduleServiceType {

    private let network: NetworkServicing

    init(network: NetworkServicing) {
        self.network = network
    }

    func fetchChildren() -> AnyPublisher<[ChildResponseDTO], NetworkError> {
        let endPoint = EndPoint.fetchChildren

        return Future { [network] promise in
            Task {
                do {
                    let response: [ChildResponseDTO] = try await network.request(endPoint: endPoint)
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

    func fetchSchedules(
        childId: Int,
        startDate: Date,
        endDate: Date
    ) -> AnyPublisher<(isFireLit: Bool, schedules: [Schedule]), NetworkError> {

        let startStr = startDate.toString(format: "yyyy-MM-dd")
        let endStr = endDate.toString(format: "yyyy-MM-dd")
        let endPoint = EndPoint.fetchSchedules(childId: childId, startDate: startStr, endDate: endStr)

        return Future { [network] promise in
            Task {
                do {
                    let response: ScheduleResponseDTO = try await network.request(endPoint: endPoint)
                    promise(.success((isFireLit: response.isFireLit, schedules: response.toEntity())))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteChildDummyData() -> AnyPublisher<Void, NetworkError> {
        Future { [network] promise in
            Task {
                do {
                    let _: EmptyResponse = try await network.request(endPoint: .deleteChildDummy)
                    promise(.success(()))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, NetworkError> {
        Future { [network] promise in
            Task {
                do {
                    let _: EmptyResponse = try await network.request(endPoint: .logout)
                    promise(.success(()))
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
