//
//  TodayStatusViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 3/2/26.
//

import Combine

final class TodayStatusViewModel: BaseViewModel, ObservableObject {

    struct State {
        var completeMissions: [MissionItem] = []
        var incompleteMissions: [MissionItem] = []
        var schedules: [ScheduleItem] = []
        var isFireLitToday: Bool = false
    }
    
    private var completeMissionDTOs: [TodayMissionDTO] = []
    private var incompleteMissionDTOs: [TodayMissionDTO] = []
    private var scheduleDTOs: [TodayScheduleDTO] = []
    private var fireLitToday: Bool = false

    @Published private(set) var state = State()

    override init() {
        super.init()
        loadMockData()
    }

    private func loadMockData() {

        completeMissionDTOs = [
            TodayMissionDTO(name: "키", reward: 100),
            TodayMissionDTO(name: "어", reward: 200),
            TodayMissionDTO(name: "로", reward: 300),
            TodayMissionDTO(name: "사", reward: 400),
            TodayMissionDTO(name: "랑", reward: 500),
            TodayMissionDTO(name: "해", reward: 600),
            TodayMissionDTO(name: "수학 숙제하기", reward: 50),
            TodayMissionDTO(name: "영어 숙제하기", reward: 50)
        ]

        incompleteMissionDTOs = [
            TodayMissionDTO(name: "수학 숙제하기", reward: 100),
            TodayMissionDTO(name: "영어 숙제하기", reward: 50)
        ]

        scheduleDTOs = [
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
                startTime: "18:00",
                endTime: "19:00",
                imageUrl: nil,
                status: .failed,
                isNowSchedule: false
            ),
            TodayScheduleDTO(
                name: "운동 하기",
                startTime: "19:00",
                endTime: "20:00",
                imageUrl: "https://lgtm-images.lgtmeow.com/2023/11/04/00/bdd7d6c6-6e9b-4192-841a-e7afea219675.webp",
                status: .complete,
                isNowSchedule: false
            ),
            TodayScheduleDTO(
                name: "독서 시간",
                startTime: "19:00",
                endTime: "19:30",
                imageUrl: nil,
                status: .failed,
                isNowSchedule: false
            )
        ]
        fireLitToday = true
        
        syncState()
    }

    func fetchTodayStatus() {
        // TODO:- API 호출
    }
    
    private func syncState() {
        state.completeMissions = completeMissionDTOs.map { $0.toItem() }
        state.incompleteMissions = incompleteMissionDTOs.map { $0.toItem() }
        state.schedules = scheduleDTOs.map { $0.toItem() }
        state.isFireLitToday = fireLitToday
    }
}
