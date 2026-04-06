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
    
    @State private var selectedSchedule: ScheduleItem?
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
            popupOverlay
        }
        .animation(.easeInOut(duration: 0.25), value: selectedSchedule != nil)
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
                        selectedSchedule = schedule
                        viewModel.didTapScheduleCard(schedule)
                    }
                )
                .padding(.top, 18)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: selectedSchedule != nil) { value in
            NotificationCenter.default.post(name: .dimNavigationBar, object: value)
        }
    }
    
    @ViewBuilder
    var popupOverlay: some View {
        if let selectedSchedule {
            Color.kBlack.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    self.selectedSchedule = nil
                    viewModel.selectedScheduleImageURL = nil
                }
            
            ScheduleImageOverlayView(
                title: selectedSchedule.title,
                imageURL: viewModel.selectedScheduleImageURL,
                onClose: {
                    self.selectedSchedule = nil
                    viewModel.selectedScheduleImageURL = nil
                }
            )
            .padding(.horizontal, 16)
            .transition(.scale.combined(with: .opacity))
            .zIndex(2)
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
