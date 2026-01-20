//
//  DailyJourneyService.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/20/26.
//

import Foundation

final class DailyJourneyService {
    static let shared = DailyJourneyService()
    private init() {}
    
    func updateDailyJourney() async throws -> DailyJourneyDTO {
        return try await BaseService.shared.request(
            endPoint: .updateDailyJourney,
            body: nil            
        )
    }
}
