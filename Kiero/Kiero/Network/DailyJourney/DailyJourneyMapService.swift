//
//  DailyJourneyMapService.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/4/26.
//

import Combine

final class DailyJourneyMapService {
    static let shared = DailyJourneyMapService()
    private init() {}
    
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
