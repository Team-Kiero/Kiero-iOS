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
    }
    
    private let remoteConfig: RemoteConfig
    private var isChecking = false
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        configureRemoteConfig()
    }
    
    // MARK: - Public
    
    func checkForUpdate() async -> AppUpdateType {
        guard !isChecking else { return .none }
        
        isChecking = true
        defer { isChecking = false }
        
        do {
            _ = try await remoteConfig.fetchAndActivate()
            
            let minimumVersion = remoteConfig[RemoteConfigKey.minimumVersion].stringValue ?? "1.0.0"
            let latestVersion = remoteConfig[RemoteConfigKey.latestVersion].stringValue ?? "1.0.0"
            
            let updateType = determineUpdateType(
                currentVersion: currentAppVersion,
                minimumVersion: minimumVersion,
                latestVersion: latestVersion
            )
            
            print("""
            ✅ [AppUpdateManager]
            bundleId: \(Bundle.main.bundleIdentifier ?? "")
            currentVersion: \(currentAppVersion)
            minimumVersion: \(minimumVersion)
            latestVersion: \(latestVersion)
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
            RemoteConfigKey.minimumVersion: "1.0.0" as NSObject,
            RemoteConfigKey.latestVersion: "1.0.0" as NSObject
        ])
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
        
        if isLowerVersion(currentVersion, than: minimumVersion) {
            return .required
        }
        
        if isLowerVersion(currentVersion, than: latestVersion) {
            return .optional
        }
        
        return .none
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
