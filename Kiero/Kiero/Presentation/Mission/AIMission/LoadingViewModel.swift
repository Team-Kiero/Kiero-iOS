//
//  LoadingViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Foundation
import Combine

final class LoadingViewModel: BaseViewModel {
    let timeoutTrigger = PassthroughSubject<Void, Never>()
    private var timerCancellable: AnyCancellable?

    override init() {
        super.init()
        startTimeoutTimer()
    }

    private func startTimeoutTimer() {
        timerCancellable = Timer.publish(every: 15.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                print("⏳ [Loading] 15초 타임아웃 발생")
                self?.timeoutTrigger.send(())
                self?.timerCancellable?.cancel()
            }
    }
    
    func stopTimer() {
        timerCancellable?.cancel()
    }
}
