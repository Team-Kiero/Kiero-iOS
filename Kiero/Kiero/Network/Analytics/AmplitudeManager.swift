//
//  AmplitudeManager.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import Foundation
import UserNotifications

import AmplitudeSwift

final class AmplitudeManager {
    static let shared = AmplitudeManager()
    private init() {}

    private var amplitude: Amplitude?

    func configure() {
        let configuration = Configuration(apiKey: Config.amplitudeAPIKey)

#if DEBUG
        configuration.logLevel = .debug
        configuration.callback = { event, code, message in
            NSLog("📊 [Amplitude] 전송 %@ | code: %d | %@", event.eventType, code, message)
        }
#endif

        amplitude = Amplitude(configuration: configuration)

        refreshUserId()
        setUserProperties([
            .userRole: AnalyticsIdentity.role.rawValue,
            .platform: "ios",
            .appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        ])
        refreshNotificationPermission()
    }

    // MARK: - Event

    func track(_ event: AnalyticsEvent) {
#if DEBUG
        NSLog("📊 [Amplitude] track %@ %@", event.name, String(describing: event.properties))
#endif

        amplitude?.track(eventType: event.name, eventProperties: event.properties)
    }

    // MARK: - Identity

    func setUserProperties(_ properties: [AnalyticsUserProperty: Any]) {
        let mapped = properties.reduce(into: [String: Any]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }

#if DEBUG
        NSLog("📊 [Amplitude] identify %@", String(describing: mapped))
#endif

        amplitude?.identify(userProperties: mapped)
    }

    func refreshNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let value: String
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral: value = "granted"
            case .denied: value = "denied"
            case .notDetermined: value = "not_determined"
            @unknown default: value = "not_determined"
            }
            self?.setUserProperties([.notificationPermission: value])
        }
    }

    func updateUserId(_ id: Int) {
        guard TokenManager.shared.getUserId() != id else { return }

        TokenManager.shared.saveUserId(id)
        refreshUserId()
    }

    func refreshUserId() {
        let userId = AnalyticsIdentity.resolveUserId()

#if DEBUG
        NSLog("📊 [Amplitude] userId %@", userId ?? "nil")
#endif

        amplitude?.setUserId(userId: userId)
    }

    func reset() {
        amplitude?.reset()
    }
}
