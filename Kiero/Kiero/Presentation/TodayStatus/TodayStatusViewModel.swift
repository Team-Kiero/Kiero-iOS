//
//  TodayStatusViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 3/2/26.
//

import UIKit
import Combine

final class TodayStatusViewModel: BaseViewModel, ObservableObject {

    @Published var completeMissions: [MissionDTO] = []
    @Published var incompleteMissions: [MissionDTO] = []
    @Published var schedules: [TodayScheduleDTO] = []
    @Published var isFireLitToday: Bool = false

    init(useMock: Bool = true) {
        super.init()
        if useMock {
            loadMockData()
        }
    }
    
    private func loadMockData() {
        completeMissions = [
            MissionDTO(name: "수학 숙제하기", reward: 50),
            MissionDTO(name: "영어 숙제하기", reward: 50),
            MissionDTO(name: "수학 숙제하기", reward: 50),
            MissionDTO(name: "영어 숙제하기", reward: 50),
            MissionDTO(name: "수학 숙제하기", reward: 50),
            MissionDTO(name: "영어 숙제하기", reward: 50),
            MissionDTO(name: "수학 숙제하기", reward: 50),
            MissionDTO(name: "영어 숙제하기", reward: 50)
        ]
        
        incompleteMissions = [
            MissionDTO(name: "수학 숙제하기", reward: 100),
            MissionDTO(name: "영어 숙제하기", reward: 50)
        ]
        
        schedules = [
            TodayScheduleDTO(
                name: "피아노 학원",
                startTime: "16:00",
                endTime: "18:00",
                imageUrl: "https://lgtm-images.lgtmeow.com/2025/08/12/09/3fcb0b3c-5476-4e4f-8b83-811bdf8868ad.webp",
                status: .complete,
                isNowSchedule: false
            ),
            TodayScheduleDTO(
                name: "운동 하기",
                startTime: "19:00",
                endTime: "20:00",
                imageUrl: "https://lgtm-images.lgtmeow.com/2023/11/04/00/bdd7d6c6-6e9b-4192-841a-e7afea219675.webp",
                status: .verified,
                isNowSchedule: true
            ),
            TodayScheduleDTO(
                name: "독서 시간",
                startTime: "19:00",
                endTime: "19:30",
                imageUrl: nil,
                status: .pending,
                isNowSchedule: false
            )
        ]
        
        isFireLitToday = true
    }
    
    func fetchTodayStatus() {
        
        // TODO: -  API 호출
    }
}
