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
    
    @State private var isMissionSheetPresented = false
    @State private var selectedMissionTab: MissionTab = .complete
    @State private var selectedSchedule: ScheduleItem?
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                backgroundView
                
                mainContent
                
                popupOverlay
                
                missionSheet(proxy: proxy)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedSchedule != nil)
        .onChange(of: selectedSchedule) { value in
            NotificationCenter.default.post(
                name: .hideTabBar,
                object: value != nil
            )
        }
    }
}

private extension TodayStatusView {
    var mainContent: some View {
        VStack(spacing: 0) {
            ProfileCard()
                .frame(height: 96)
                .padding(.top, 64)
            
            MissionButtonBar(
                completeCount: viewModel.state.completeMissions.count,
                incompleteCount: viewModel.state.incompleteMissions.count,
                completeAction: {
                    selectedMissionTab = .complete
                    NotificationCenter.default.post(name: .hideTabBar, object: true)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isMissionSheetPresented = true
                    }
                },
                incompleteAction: {
                    selectedMissionTab = .incomplete
                    NotificationCenter.default.post(name: .hideTabBar, object: true)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isMissionSheetPresented = true
                    }
                }
            )
            .padding(.horizontal, 27)
            
            ScrollView {
                ScheduleSectionView(
                    schedules: viewModel.state.schedules,
                    isFireLitToday: viewModel.state.isFireLitToday,
                    onTapSchedule: { schedule in
                        isMissionSheetPresented = false
                        selectedSchedule = schedule
                    }
                )
                .padding(.top, 18)
            }
        }
        .onChange(of: isMissionSheetPresented) { value in
            NotificationCenter.default.post(name: .dimNavigationBar, object: value)
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
    }
    
    @ViewBuilder
    func missionSheet(proxy: GeometryProxy) -> some View {
        let shouldShowSheet = isMissionSheetPresented && selectedSchedule == nil

        Color.kBlack.opacity(shouldShowSheet ? 0.75 : 0)
            .ignoresSafeArea()
            .allowsHitTesting(shouldShowSheet)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isMissionSheetPresented = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    NotificationCenter.default.post(name: .hideTabBar, object: false)
                }
            }
            .zIndex(3)

        VStack {
            Spacer()

            MissionBottomSheet(
                selectedTab: $selectedMissionTab,
                isPresented: $isMissionSheetPresented,
                completeMissions: viewModel.state.completeMissions,
                incompleteMissions: viewModel.state.incompleteMissions
            )
            .offset(y: shouldShowSheet ? 0 : proxy.size.height + 10)
            .opacity(shouldShowSheet ? 1 : 0)
        }
        .ignoresSafeArea(edges: .bottom)
        .zIndex(4)
        .animation(.easeInOut(duration: 0.25), value: shouldShowSheet)
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
