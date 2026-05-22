//
//  DailyJourneyMapService.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/4/26.
//

import Combine

protocol DailyJourneyMapServiceType {
    func fetchJourneyList() -> AnyPublisher<DailyJourneyMapData, NetworkError>
}

final class DailyJourneyMapService: DailyJourneyMapServiceType {
    static let shared = DailyJourneyMapService()
    init() {}
    
    func fetchJourneyList() -> AnyPublisher<DailyJourneyMapData, NetworkError> {
        return Future<DailyJourneyMapData, NetworkError> { promise in
            Task {
                do {
                    let response: DailyJourneyMapData = try await BaseService.shared.request(
                        endPoint: .fetchJourneyList,
                        body: nil
                    )
                    promise(.success(response))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
}
