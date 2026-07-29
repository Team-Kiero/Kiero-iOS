//
//  AnalyticsEvent.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import Foundation

enum AnalyticsEvent: String {

    // MARK: - 공통 / 온보딩

    case appOpened = "app_opened"
    case roleSelected = "role_selected"
    case loginCompleted = "login_completed"
    case termsAgreementCompleted = "terms_agreement_completed"
    case inviteCodeCreated = "invite_code_created"
    case childConnectionCompleted = "child_connection_completed"
    case onboardingCompleted = "onboarding_completed"

    // MARK: - 부모 핵심 행동

    case scheduleCreated = "schedule_created"
    case missionCreated = "mission_created"
    case rewardCreated = "reward_created"

    // MARK: - 자녀 핵심 행동

    case scheduleAuthStarted = "schedule_auth_started"
    case scheduleAuthCompleted = "schedule_auth_completed"
    case scheduleSkipped = "schedule_skipped"
    case dailyJourneyCompleted = "daily_journey_completed"
    case missionCompleted = "mission_completed"
    case wishPurchased = "wish_purchased"

    // MARK: - 푸시 / 알림

    case pushPermissionResult = "push_permission_result"
    case pushClicked = "push_clicked"
}

enum AnalyticsEventProperty {
    static let role = "role"
    static let inviteCodeHash = "invite_code_hash"
    static let pushType = "push_type"
    static let granted = "granted"
    static let source = "source"
    static let loginMethod = "login_method"
    static let selectedRole = "selected_role"
    static let count = "count"
    static let earnedCoin = "earned_coin"
    static let stoneCount = "stone_count"
    static let price = "price"
}

enum AnalyticsUserProperty: String {
    case role = "role"
    case loginMethod = "login_method"
    case childConnected = "child_connected"
    case pushEnabled = "push_enabled"
}

enum AnalyticsLoginMethod: String {
    case kakao
    case apple
    case inviteCode = "invite_code"
}
