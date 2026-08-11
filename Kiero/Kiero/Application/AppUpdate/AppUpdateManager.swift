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
        static let parentMinimumVersion = "parent_minimum_version"
        static let parentLatestVersion = "parent_latest_version"
        
        static let childMinimumVersion = "child_minimum_version"
        static let childLatestVersion = "child_latest_version"
    }
    
    private let remoteConfig: RemoteConfig
    
    private var isChecking = false
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        configureRemoteConfig()
    }
    
    // MARK: - Public
    
    func checkForUpdate() async -> AppUpdateType {
        guard !isChecking else {
            return .none
        }
        
        isChecking = true
        defer { isChecking = false }
        
        do {
            _ = try await remoteConfig.fetchAndActivate()
            
            let versions = remoteVersions()
            
            let updateType = determineUpdateType(
                currentVersion: currentAppVersion,
                minimumVersion: versions.minimum,
                latestVersion: versions.latest
            )
            
            print("""
            
            ✅ [AppUpdateManager]
            currentVersion: \(currentAppVersion)
            minimumVersion: \(versions.minimum)
            latestVersion: \(versions.latest)
            updateType: \(updateType)
            
            """)
            
            return updateType
            
        } catch {
            print("❌ [AppUpdateManager] Remote Config fetch 실패: \(error)")
            
            return .none
        }
    }
    
    // MARK: - Remote Config
    
    private func configureRemoteConfig() {
        let settings = RemoteConfigSettings()
        
#if DEBUG
        settings.minimumFetchInterval = 0
#else
        settings.minimumFetchInterval = 60 * 60
#endif
        
        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults([
            RemoteConfigKey.parentMinimumVersion: "1.0.0" as NSObject,
            RemoteConfigKey.parentLatestVersion: "1.0.0" as NSObject,
            RemoteConfigKey.childMinimumVersion: "1.0.0" as NSObject,
            RemoteConfigKey.childLatestVersion: "1.0.0" as NSObject
        ])
    }
    
    private func remoteVersions() -> (
        minimum: String,
        latest: String
    ) {
#if KIERO_PARENT
        let minimumKey = RemoteConfigKey.parentMinimumVersion
        let latestKey = RemoteConfigKey.parentLatestVersion
#elseif KIERO_CHILD
        let minimumKey = RemoteConfigKey.childMinimumVersion
        let latestKey = RemoteConfigKey.childLatestVersion
#else
        let minimumKey = RemoteConfigKey.parentMinimumVersion
        let latestKey = RemoteConfigKey.parentLatestVersion
#endif
        
        return (
            minimum: remoteConfig[minimumKey].stringValue ?? "1.0.0",
            latest: remoteConfig[latestKey].stringValue ?? "1.0.0"
        )
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
        
        if isLowerVersion(
            currentVersion,
            than: minimumVersion
        ) {
            return .required
        }
        
        if isLowerVersion(
            currentVersion,
            than: latestVersion
        ) {
            return .optional
        }
        
        return .none
    }
    
    private func isLowerVersion(
        _ lhs: String,
        than rhs: String
    ) -> Bool {
        lhs.compare(
            rhs,
            options: .numeric
        ) == .orderedAscending
    }
}
