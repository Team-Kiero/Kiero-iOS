//
//  TodayStatusViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 3/2/26.
//

import Combine
import Foundation

final class TodayStatusViewModel: BaseViewModel, ObservableObject {

    struct State {
        var completeMissions: [MissionItem] = []
        var incompleteMissions: [MissionItem] = []
        var schedules: [ScheduleItem] = []
        var isFireLitToday: Bool = false
    }

    @Published private(set) var state = State()

    private var completeMissions: [MissionItem] = []
    private var incompleteMissions: [MissionItem] = []
    private var schedules: [ScheduleItem] = []
    private var isFireLitToday: Bool = false

    override init() {
        super.init()
        loadMockData()
    }

    private func loadMockData() {
        completeMissions = [
            MissionItem(title: "키", reward: 100),
            MissionItem(title: "어", reward: 200),
            MissionItem(title: "로", reward: 300),
            MissionItem(title: "사", reward: 400),
            MissionItem(title: "랑", reward: 500),
            MissionItem(title: "해", reward: 600),
            MissionItem(title: "수학 숙제하기", reward: 50),
            MissionItem(title: "영어 숙제하기", reward: 50)
        ]

        incompleteMissions = [
            MissionItem(title: "수학 숙제하기", reward: 100),
            MissionItem(title: "영어 숙제하기", reward: 50)
        ]

        schedules = [
            ScheduleItem(
                title: "피아노 학원",
                startTime: "16:00",
                endTime: "18:00",
                imageURL: URL(string: "https://lgtm-images.lgtmeow.com/2025/08/12/09/3fcb0b3c-5476-4e4f-8b83-811bdf8868ad.webp"),
                status: .complete,
                isNowSchedule: false
            ),
            ScheduleItem(
                title: "운동 하기",
                startTime: "18:00",
                endTime: "19:00",
                imageURL: nil,
                status: .failed,
                isNowSchedule: false
            ),
            ScheduleItem(
                title: "운동 하기",
                startTime: "19:00",
                endTime: "20:00",
                imageURL: URL(string: "https://lgtm-images.lgtmeow.com/2023/11/04/00/bdd7d6c6-6e9b-4192-841a-e7afea219675.webp"),
                status: .complete,
                isNowSchedule: false
            ),
            ScheduleItem(
                title: "독서 시간",
                startTime: "19:00",
                endTime: "19:30",
                imageURL: nil,
                status: .failed,
                isNowSchedule: false
            )
        ]

        isFireLitToday = true
        syncState()
    }

    private func syncState() {
        state.completeMissions = completeMissions
        state.incompleteMissions = incompleteMissions
        state.schedules = schedules
        state.isFireLitToday = isFireLitToday
    }

    func fetchTodayStatus() {
//         TODO: API 호출
//        
//         let dto: TodayStatusDTO
//        
//         completeMissions = dto.completeMissions.map { $0.toItem() }
//         incompleteMissions = dto.incompleteMissions.map { $0.toItem() }
//         schedules = dto.schedules.map { $0.toItem() }
//         isFireLitToday = dto.isFireLitToday
//        
//         syncState()
    }
}
