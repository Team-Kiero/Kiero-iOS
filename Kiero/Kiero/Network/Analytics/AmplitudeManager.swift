//
//  AmplitudeManager.swift
//  Kiero
//

import Foundation

import AmplitudeSwift

final class AmplitudeManager {
    static let shared = AmplitudeManager()
    private init() {}
    
    private var amplitude: Amplitude?
    
    func configure() {
        amplitude = Amplitude(
            configuration: Configuration(apiKey: Config.amplitudeAPIKey)
        )
    }
}
