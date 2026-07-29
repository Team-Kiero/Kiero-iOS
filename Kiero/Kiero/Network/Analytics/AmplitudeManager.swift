//
//  AmplitudeManager.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import Foundation

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
        setUserProperties([.role: AnalyticsIdentity.role])
    }

    // MARK: - Event

    func track(_ event: AnalyticsEvent, properties: [String: Any]? = nil) {
        var merged = properties ?? [:]
        merged[AnalyticsEventProperty.role] = AnalyticsIdentity.role

#if DEBUG
        NSLog("📊 [Amplitude] track %@ %@", event.rawValue, String(describing: merged))
#endif

        amplitude?.track(eventType: event.rawValue, eventProperties: merged)
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
