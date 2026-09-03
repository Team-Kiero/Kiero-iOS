//
//  AppUpdateManager.swift
//  Kiero
//
//  Created by 안치욱 on 8/8/26.
//

import Foundation

import FirebaseRemoteConfig

@MainActor
final class AppUpdateManager {

    static let shared = AppUpdateManager()

    private enum RemoteConfigKey {
        static let latestVersion = "ios_latest_version"
        static let minimumVersion = "ios_min_force_version"
        static let defaultVersion = "1.0.0"
    }

    private let remoteConfig: RemoteConfig
    private var updateCheckTask: Task<AppUpdateType, Never>?

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        configureRemoteConfig()
    }

    // MARK: - Public

    func checkForUpdate() async -> AppUpdateType {
        if let updateCheckTask {
            return await updateCheckTask.value
        }

        let task = Task { () -> AppUpdateType in
            do {
                _ = try await remoteConfig.fetchAndActivate()
            } catch {
#if DEBUG
                print("❌ Remote Config fetch 실패: \(error)")
#endif
            }

            return determineUpdateTypeFromActiveConfig()
        }

        updateCheckTask = task

        let result = await task.value
        updateCheckTask = nil

        return result
    }

    // MARK: - Remote Config

    private func configureRemoteConfig() {
        let settings = RemoteConfigSettings()

        // 강제 업데이트 정책이 게시되면 다음 검사에서 바로 반영합니다.
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.setDefaults([
            RemoteConfigKey.minimumVersion: RemoteConfigKey.defaultVersion as NSObject,
            RemoteConfigKey.latestVersion: RemoteConfigKey.defaultVersion as NSObject
        ])
    }

    private func determineUpdateTypeFromActiveConfig() -> AppUpdateType {
        let minimumVersion = remoteVersion(forKey: RemoteConfigKey.minimumVersion)
        let latestVersion = remoteVersion(forKey: RemoteConfigKey.latestVersion)

        let updateType = determineUpdateType(
            currentVersion: currentAppVersion,
            minimumVersion: minimumVersion,
            latestVersion: latestVersion
        )

#if DEBUG
        print("""
        ✅ [AppUpdateManager]
        bundleId: \(Bundle.main.bundleIdentifier ?? "")
        currentVersion: \(currentAppVersion)
        minimumVersion: \(minimumVersion)
        latestVersion: \(latestVersion)
        updateType: \(updateType)
        """)
#endif

        return updateType
    }

    private func remoteVersion(forKey key: String) -> String {
        let version = remoteConfig[key].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !version.isEmpty else {
            return RemoteConfigKey.defaultVersion
        }

        return version
    }

    // MARK: - Version

    private var currentAppVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "0.0.0"
    }

    private func determineUpdateType(
        currentVersion: String,
        minimumVersion: String,
        latestVersion: String
    ) -> AppUpdateType {
        guard isValidVersion(currentVersion),
              isValidVersion(minimumVersion),
              isValidVersion(latestVersion) else {
#if DEBUG
            print("❌ [AppUpdateManager] 잘못된 버전 형식")
#endif
            return .none
        }

        let effectiveMinimumVersion = isLowerVersion(latestVersion, than: minimumVersion)
            ? latestVersion
            : minimumVersion

        if isLowerVersion(currentVersion, than: effectiveMinimumVersion) {
            return .required
        }

        if isLowerVersion(currentVersion, than: latestVersion) {
            return .optional
        }

        return .none
    }

    private func isValidVersion(_ version: String) -> Bool {
        let components = version.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        return (1...3).contains(components.count)
            && components.allSatisfy { component in
                guard let number = Int(component) else { return false }
                return number >= 0
            }
    }

    private func isLowerVersion(_ lhs: String, than rhs: String) -> Bool {
        normalizedVersion(lhs).compare(
            normalizedVersion(rhs),
            options: .numeric
        ) == .orderedAscending
    }

    private func normalizedVersion(_ version: String) -> String {
        var components = version.split(separator: ".").map(String.init)

        while components.count < 3 {
            components.append("0")
        }

        return components.prefix(3).joined(separator: ".")
    }
}
