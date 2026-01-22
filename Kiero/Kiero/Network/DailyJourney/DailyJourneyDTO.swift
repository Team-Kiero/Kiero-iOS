//
//  DailyJourneyDTO.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/20/26.
//

import Foundation

struct DailyJourneyDTO: Decodable {
    let scheduleDetailId: Int?
    let scheduleOrder: Int
    let startTime: String?
    let endTime: String?
    let name: String?
    let stoneType: StoneType?
    let totalSchedule: Int
    let earnedStones: Int?
    let scheduleStatus: ScheduleStatus
    let isSkippable: Bool
    let isNowScheduleVerified: Bool
}

enum ScheduleStatus: String, Decodable {
    case noSchedule = "NO_SCHEDULE"
    case firstSchedule = "FIRST_SCHEDULE"
    case nextScheduleExist = "NEXT_SCHEDULE_EXIST"
    case nowScheduleExist = "NOW_SCHEDULE_EXIST"
    case fireNotLit = "FIRE_NOT_LIT"
    case fireLit = "FIRE_LIT"
}

enum StoneType: String, Decodable {
    case courage = "COURAGE"
    case grit = "GRIT"
    case wisdom = "WISDOM"
}
