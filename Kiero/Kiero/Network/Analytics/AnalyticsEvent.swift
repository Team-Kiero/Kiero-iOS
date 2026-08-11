//
//  AnalyticsEvent.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import Foundation

enum AnalyticsEvent {

    // MARK: - 공통 / 온보딩

    case appOpened
    case roleSelected(role: AnalyticsRole, source: RoleSelectSource)
    case loginCompleted(method: AnalyticsLoginMethod)
    case termsAgreementCompleted
    case inviteCodeCreated(codeHash: String, source: InviteCodeSource)
    case childConnectionCompleted(codeHash: String)
    case onboardingCompleted

    // MARK: - 부모 핵심 행동

    case scheduleCreated
    case missionCreated(source: MissionCreateSource, count: Int?)
    case rewardCreated

    // MARK: - 자녀 핵심 행동

    case scheduleAuthStarted
    case scheduleAuthCompleted
    case scheduleSkipped
    case dailyJourneyCompleted(earnedCoin: Int, stoneCount: Int)
    case missionCompleted
    case wishPurchased(price: Int)

    // MARK: - 푸시 / 알림

    case pushPermissionResult(granted: Bool, source: PushPromptSource)
    case pushClicked(pushType: String)
}

extension AnalyticsEvent {

    var name: String {
        switch self {
        case .appOpened: return "app_opened"
        case .roleSelected: return "role_selected"
        case .loginCompleted: return "login_completed"
        case .termsAgreementCompleted: return "terms_agreement_completed"
        case .inviteCodeCreated: return "invite_code_created"
        case .childConnectionCompleted: return "child_connection_completed"
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
        case .pushPermissionResult: return "push_permission_result"
        case .pushClicked: return "push_clicked"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .roleSelected(let role, let source):
            return ["selected_role": role.rawValue, "source": source.rawValue]

        case .loginCompleted(let method):
            return ["login_method": method.rawValue]

        case .inviteCodeCreated(let codeHash, let source):
            return ["invite_code_hash": codeHash, "source": source.rawValue]

        case .childConnectionCompleted(let codeHash):
            return ["invite_code_hash": codeHash]

        case .missionCreated(let source, let count):
            var properties: [String: Any] = ["source": source.rawValue]
            properties["count"] = count
            return properties

        case .dailyJourneyCompleted(let earnedCoin, let stoneCount):
            return ["earned_coin": earnedCoin, "stone_count": stoneCount]

        case .wishPurchased(let price):
            return ["price": price]

        case .pushPermissionResult(let granted, let source):
            return ["granted": granted, "source": source.rawValue]

        case .pushClicked(let pushType):
            return ["push_type": pushType]

        case .appOpened, .termsAgreementCompleted, .onboardingCompleted,
             .scheduleCreated, .rewardCreated, .scheduleAuthStarted,
             .scheduleAuthCompleted, .scheduleSkipped, .missionCompleted:
            return [:]
        }
    }
}

// MARK: - Property Value

enum AnalyticsRole: String {
    case parent
    case child
}

enum AnalyticsLoginMethod: String {
    case kakao
    case apple
    case inviteCode = "invite_code"
}

enum RoleSelectSource: String {
    case authGate = "auth_gate"
    case logoutDialog = "logout_dialog"
}

enum InviteCodeSource: String {
    case onboarding
    case reissue
    case childManage = "child_manage"
}

enum MissionCreateSource: String {
    case manual
    case ai
}

enum PushPromptSource: String {
    case dailyJourney = "daily_journey"
    case todayStatus = "today_status"
    case mySpace = "my_space"
    case myPage = "my_page"
}

// MARK: - User Property

enum AnalyticsUserProperty: String {
    case role = "role"
    case loginMethod = "login_method"
    case childConnected = "child_connected"
    case pushEnabled = "push_enabled"
}
