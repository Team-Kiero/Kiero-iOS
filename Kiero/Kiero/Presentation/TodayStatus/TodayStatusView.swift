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
        .onAppear {
            viewModel.fetchTodayStatus()
        }
        .onChange(of: isMissionSheetPresented) { value in
            NotificationCenter.default.post(
                name: .hideTabBar,
                object: value
            )
        }
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
            
            NavigationBarWrapper(type: .main())
                .frame(height: 41)
                .padding(.top, 9)
            
            ProfileCard(name: viewModel.childFirstName)
                .frame(height: 96)
                .padding(.top, 14)
            
            MissionButtonBar(
                completeCount: viewModel.completeMissions.count,
                incompleteCount: viewModel.incompleteMissions.count,
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
                    schedules: viewModel.schedules,
                    isFireLitToday: viewModel.isFireLitToday,
                    onTapSchedule: { schedule in
                        viewModel.selectedScheduleImageURL = nil
                        selectedSchedule = schedule
                        viewModel.didTapScheduleCard(schedule)
                    }
                )
                .padding(.top, 18)
                .padding(.bottom, 100)
            }
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
    
    @ViewBuilder
    func missionSheet(proxy: GeometryProxy) -> some View {
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
                completeMissions: viewModel.completeMissions,
                incompleteMissions: viewModel.incompleteMissions
            )
            .offset(y: isMissionSheetPresented ? 0 : proxy.size.height)
        }
        .ignoresSafeArea(edges: .bottom)
        .zIndex(4)
        .animation(.easeInOut(duration: 0.25), value: isMissionSheetPresented)
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
