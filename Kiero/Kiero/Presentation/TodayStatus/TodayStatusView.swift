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
    
    @ObservedObject var viewModel: TodayStatusViewModel
    
    let onMissionSheetRequested: (MissionTab) -> Void
    let onScheduleOverlayRequested: (ScheduleItem) -> Void
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
    }
}

private extension TodayStatusView {
    var mainContent: some View {
        VStack(spacing: 0) {
            ProfileCard(name: viewModel.childFirstName, date: viewModel.todayDate)
                .frame(height: 96)
                .padding(.top, 64)
            
            MissionButtonBar(
                completeCount: viewModel.completeMissions.count,
                incompleteCount: viewModel.incompleteMissions.count,
                completeAction: {
                    onMissionSheetRequested(.complete)
                },
                incompleteAction: {
                    onMissionSheetRequested(.incomplete)
                }
            )
            .padding(.horizontal, 27)

            ScrollView {
                ScheduleSectionView(
                    schedules: viewModel.schedules,
                    isFireLitToday: viewModel.isFireLitToday,
                    onTapSchedule: { schedule in
                        onScheduleOverlayRequested(schedule)
                    }
                )
                .padding(.top, 18)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    var backgroundView: some View {
        VStack(spacing: 0) {
            Color.gray900
                .ignoresSafeArea()
                .frame(height: 201)
            
            Color.kBlack
                .ignoresSafeArea()
        }
    }
}
