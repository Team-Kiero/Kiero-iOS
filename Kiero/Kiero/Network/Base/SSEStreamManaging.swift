//
//  SSEStreamManaging.swift
//  Kiero
//
//  Created by 안치욱 on 2/26/26.
//

protocol SseStreamManaging {
    func startIfNeeded(initialToken: String, onEvent: @escaping (SseEventPayload) -> Void)
    func stop()
}

extension SseStreamManager: SseStreamManaging {}
