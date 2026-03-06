//
//  DailyJourneyMapModel.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/4/26.
//

import Foundation

struct DailyJourneyMapResponse: Decodable {
    let status: Int
    let message: String
    let data: DailyJourneyMapData
}

struct DailyJourneyMapData: Decodable {
    let scheduleCount: Int
    let schedules: [DailyJourneyMapSchedule]
}

struct DailyJourneyMapSchedule: Decodable, Identifiable {
    let name: String
    let startTime: String
    let endTime: String
    let isOngoing: Bool
    let stoneType: StoneType
    let status: ScheduleStatus
    
    var id: String { "\(name)_\(startTime)_\(endTime)" }
    
    enum StoneType: String, Decodable {
        case COURAGE
        case GRIT
        case WISDOM
    }
    
    enum ScheduleStatus: String, Decodable {
        case PENDING
        case COMPLETE
        case FAILED
        case SKIPPED
        case VERIFIED
    }
}
