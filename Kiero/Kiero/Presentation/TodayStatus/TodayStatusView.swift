//
//  TodayStatusView.swift
//  Kiero
//
//  Created by 안치욱 on 3/4/26.
//

import SwiftUI

enum MissionTab {
    case complete
    case incomplete
}

struct TodayStatusView: View {
    let completeMissions: [MissionDTO]
    let incompleteMissions: [MissionDTO]
    let schedules: [TodayScheduleDTO]
    let isFireLitToday: Bool

    @State private var isMissionSheetPresented = false
    @State private var selectedMissionTab: MissionTab = .complete
    @State private var selectedSchedule: TodayScheduleDTO?

    var body: some View {
        ZStack {
            
            backgroundView
            
            VStack {
                ProfileCard()

                MissionButtonBar(
                    completeCount: completeMissions.count,
                    incompleteCount: incompleteMissions.count,
                    completeAction: {
                        selectedMissionTab = .complete
                        isMissionSheetPresented = true
                    },
                    incompleteAction: {
                        selectedMissionTab = .incomplete
                        isMissionSheetPresented = true
                    }
                )
                .padding(.horizontal, 27)

                ScrollView {
                    ScheduleSectionView(
                        schedules: schedules,
                        isFireLitToday: isFireLitToday,
                        onTapSchedule: { schedule in
                            guard schedule.imageUrl != nil else { return }
                            selectedSchedule = schedule
                        }
                    )
                }

                Spacer()
            }

            if let selectedSchedule {
                Color.kBlack.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.selectedSchedule = nil
                    }

                ScheduleImageOverlayView(
                    schedule: selectedSchedule,
                    onClose: {
                        self.selectedSchedule = nil
                    }
                )
                .padding(.horizontal, 16)
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }

            Color.kBlack.opacity(isMissionSheetPresented ? 0.75 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(isMissionSheetPresented)
                .onTapGesture {
                    withAnimation {
                        isMissionSheetPresented = false
                    }
                }
                .zIndex(3)
            
            VStack {
                Spacer()
                
                MissionBottomSheet(
                    selectedTab: $selectedMissionTab,
                    isPresented: $isMissionSheetPresented,
                    completeMissions: completeMissions,
                    incompleteMissions: incompleteMissions
                )
                .frame(maxWidth: .infinity)
                .offset(y: isMissionSheetPresented ? 0 : 911)
            }
            .ignoresSafeArea(edges: .bottom)
            .zIndex(4)
            .animation(.easeInOut(duration: 0.25), value: isMissionSheetPresented)
        }
        .animation(.easeInOut(duration: 0.25), value: selectedSchedule != nil)
    }
}

private extension TodayStatusView {
    
    var backgroundView: some View {
        VStack(spacing: 0) {
            Color.gray900
                .ignoresSafeArea()
                .frame(height: 245)
            
            Color.kBlack
                .ignoresSafeArea()
        }
    }
}

#Preview {
    TodayStatusView(
        completeMissions: [
        ],
        incompleteMissions: [
            MissionDTO(name: "수학 숙제하기", reward: 50),
            MissionDTO(name: "영어 숙제하기", reward: 50)
        ],
        schedules: [
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
        ],
        isFireLitToday: true
    )
}
