//
//  MissionBottomSheet.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI

struct MissionBottomSheet: View {

    @Binding var selectedTab: MissionTab
    @Binding var isPresented: Bool

    let completeMissions: [MissionItem]
    let incompleteMissions: [MissionItem]

    var body: some View {
        VStack(spacing: 0) {

            NavigationBarWrapper(
                type: .titleClose(title: "오늘의 미션"),
                onRightTap: {
                    isPresented = false
                }
            )
            .frame(height: 40)

            Rectangle()
                .fill(Color.gray800)
                .frame(height: 1)

            tabView
                .padding(.top, 20)

            missionListView
                .padding(.top, 16)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 750)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray900)
        )
    }
}

private extension MissionBottomSheet {
    var tabView: some View {
        HStack(spacing: 20) {
            Button {
                selectedTab = .complete
            } label: {
                Text("완료")
                    .font(Font(UIFont.title4_14_SB))
                    .foregroundStyle(selectedTab == .complete ? .main : .gray600)
            }
            .buttonStyle(.plain)

            Button {
                selectedTab = .incomplete
            } label: {
                Text("미완료")
                    .font(Font(UIFont.title4_14_SB))
                    .foregroundStyle(selectedTab == .incomplete ? .main : .gray600)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    var missionListView: some View {
        if currentMissions.isEmpty {
            Spacer()
            
            StatusEmptyView(
                type: selectedTab == .complete ? .missionEmpty : .missionComplete
            )
            
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(currentMissions) { mission in
                        MissionCard(mission: mission)
                    }
                }
                .padding(.horizontal, 13)
            }
            .frame(maxHeight: .infinity)
        }
    }

    var currentMissions: [MissionItem] {
        switch selectedTab {
        case .complete:
            return completeMissions
        case .incomplete:
            return incompleteMissions
        }
    }
}
