//
//  AnalyticsEvent.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import Foundation

enum AnalyticsEvent {
    case appOpened
    case onboardingCompleted
    case scheduleCreated(scheduleId: String, isRecurring: Bool, selectedDayCount: Int, durationMinutes: Int)
    case missionCreated(creationMethod: MissionCreationMethod, dueDateType: MissionDueDateType?, rewardGold: Int, missionCount: Int, missionId: String?)
    case rewardCreated(rewardId: String, goldCost: Int)
    case scheduleAuthStarted(scheduleId: String)
    case scheduleAuthCompleted(scheduleId: String)
    case scheduleSkipped(scheduleId: String)
    case dailyJourneyCompleted(completedScheduleCount: Int, totalScheduleCount: Int)
    case missionCompleted(rewardGold: Int, missionId: String)
    case wishPurchased(rewardId: String, goldCost: Int)
    case pushClicked(pushType: String, destinationScreen: AnalyticsDestinationScreen)
}

extension AnalyticsEvent {
    var name: String {
        switch self {
        case .appOpened: return "app_opened"
        case .onboardingCompleted: return "onboarding_completed"
        case .scheduleCreated: return "schedule_created"
        case .missionCreated: return "mission_created"
        case .rewardCreated: return "reward_created"
        case .scheduleAuthStarted: return "schedule_auth_started"
        case .scheduleAuthCompleted: return "schedule_auth_completed"
        case .scheduleSkipped: return "schedule_skipped"
        case .dailyJourneyCompleted: return "daily_journey_completed"
        case .missionCompleted: return "mission_completed"
        case .wishPurchased: return "wish_purchased"
        case .pushClicked: return "push_clicked"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .scheduleCreated(let scheduleId, let isRecurring, let selectedDayCount, let durationMinutes):
            return ["schedule_id": scheduleId, "is_recurring": isRecurring, "selected_day_count": selectedDayCount, "duration_minutes": durationMinutes]
        case .missionCreated(let creationMethod, let dueDateType, let rewardGold, let missionCount, let missionId):
            var properties: [String: Any] = ["creation_method": creationMethod.rawValue, "reward_gold": rewardGold, "mission_count": missionCount]
            if let dueDateType { properties["due_date_type"] = dueDateType.rawValue }
            if let missionId { properties["mission_id"] = missionId }
            return properties
        case .rewardCreated(let rewardId, let goldCost), .wishPurchased(let rewardId, let goldCost):
            return ["reward_id": rewardId, "gold_cost": goldCost]
        case .scheduleAuthStarted(let scheduleId), .scheduleAuthCompleted(let scheduleId), .scheduleSkipped(let scheduleId):
            return ["schedule_id": scheduleId]
        case .dailyJourneyCompleted(let completedScheduleCount, let totalScheduleCount):
            return ["completed_schedule_count": completedScheduleCount, "total_schedule_count": totalScheduleCount]
        case .missionCompleted(let rewardGold, let missionId):
            return ["reward_gold": rewardGold, "mission_id": missionId]
        case .pushClicked(let pushType, let destinationScreen):
            return ["push_type": pushType, "destination_screen": destinationScreen.rawValue]
        case .appOpened, .onboardingCompleted:
            return [:]
        }
    }
}

enum AnalyticsRole: String {
    case parent
    case child
}

enum MissionCreationMethod: String {
    case manual
    case ai
}

enum MissionDueDateType: String {
    case today
    case tomorrow
    case future
}

enum AnalyticsDestinationScreen: String {
    case parentHome = "parent_home"
    case parentNotificationFeed = "parent_notification_feed"
    case childJourney = "child_journey"
    case childMission = "child_mission"
}

enum AnalyticsUserProperty: String {
    case userRole = "user_role"
    case loginMethod = "login_method"
    case notificationPermission = "notification_permission"
    case pushEnabled = "push_enabled"
    case platform
    case appVersion = "app_version"
    case familyConnectionId = "family_connection_id"
}
