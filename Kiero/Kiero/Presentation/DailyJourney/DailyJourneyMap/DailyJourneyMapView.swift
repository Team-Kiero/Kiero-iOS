//
//  DailyJourneyMapView.swift
//  Kiero
//
//  Created by Hyunseo Han on 3/4/26.
//

import SwiftUI

struct DailyJourneyMapView: View {
    
    @ObservedObject var viewModel: DailyJourneyMapViewModel
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            GeometryReader { geometry in
                let scaleX = geometry.size.width / 375
                let scaleY = geometry.size.height / 812
                
                Image(.imgBackground)
                    .resizable()
                    .frame(width: 657.79 * scaleX, height: 701.11 * scaleY)
                    .opacity(0.12)
                    .offset(x: -191.67 * scaleX, y: 53.4 * scaleY)
                    .overlay(
                        VStack {
                            LinearGradient(
                                colors: [Color.kBlack, Color.kBlack.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                            
                            Spacer()
                        }
                            .offset(y: 53.4 * scaleY)
                    )
            }
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    NavigationBarWrapper(
                        type: .back(title: viewModel.todayDateText),
                        onLeftTap: {
                            viewModel.confirmButtonTapSubject.send()
                        }
                    )
                    .frame(height: 44)
                    .padding(.horizontal, 8)
                    
                    if let data = viewModel.scheduleData {
                        if data.scheduleCount > 0 {
                            scheduleListContent(
                                data: data,
                                scrollAreaHeight: geometry.size.height - 156
                            )
                        } else {
                            emptyStateContent
                        }
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    CTAButtonWrapper(
                        title: "확인",
                        style: .gray100,
                        size: .h49,
                        onTap: {
                            viewModel.confirmButtonTapSubject.send()
                        }
                    )
                    .frame(height: 49)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

private extension DailyJourneyMapView {
    func scheduleListContent(data: DailyJourneyMapData, scrollAreaHeight: CGFloat) -> some View {
        let bannerHeight: CGFloat = 12 + 36
        
        return VStack(spacing: 0) {
            HStack {
                Text("오늘은 \(data.scheduleCount)개의 여정이 있어!")
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(.gray200)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray900)
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 25)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(Array(data.schedules.enumerated()), id: \.element.id) { index, schedule in
                        let hasOngoing = data.schedules.contains { $0.isOngoing }
                        let isNext: Bool = {
                            guard !hasOngoing,
                                  !schedule.isOngoing,
                                  schedule.status == .PENDING else { return false }
                            let isFirstPending = data.schedules.prefix(index).allSatisfy { $0.status != .PENDING || $0.isOngoing }
                            return isFirstPending
                        }()
                        
                        DailyJourneyMapStateRowView(
                            name: schedule.name,
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            isOngoing: schedule.isOngoing,
                            stoneType: schedule.stoneType.rawValue,
                            status: schedule.status.rawValue,
                            isNext: isNext
                        )
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 40)
            }
            .frame(height: scrollAreaHeight - 44 - bannerHeight)
            .scrollDisabled(data.schedules.count < 6)
        }
    }
    
    var emptyStateContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(.icFireMint)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30) // 이미지 사이즈
                .frame(width: 50, height: 50) // 배경 사이즈
                .background(
                    Circle()
                        .fill(Color.gray900)
                        .overlay(
                            Circle()
                                .stroke(Color.main, lineWidth: 1)
                        )
                        .shadow(color: Color.main, radius: 3, x: 0, y: 0)
                )
                .padding(.bottom, 22)
            
            Text("오늘은 등록된 여정이 없어!")
                .font(Font(UIFont.title3_16_SB))
                .foregroundStyle(.white)
                .padding(.bottom, 5)
            
            Text("여정이 없는 오늘 여유를 즐겨봐!")
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.gray300)
            
            Spacer()
        }
    }
}

#if DEBUG
struct DailyJourneyMapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. 진행 중 일정 있음 → 다음 일정 하이라이팅 X
            DailyJourneyMapView(viewModel: {
                let vm = DailyJourneyMapViewModel()
                vm.scheduleData = DailyJourneyMapData(
                    scheduleCount: 3,
                    schedules: [
                        DailyJourneyMapSchedule(
                            name: "피아노 학원",
                            startTime: "08:00:00",
                            endTime: "09:30:00",
                            isOngoing: true,
                            stoneType: .COURAGE,
                            status: .COMPLETE
                        ),
                        DailyJourneyMapSchedule(
                            name: "영어 학원",
                            startTime: "10:00:00",
                            endTime: "11:30:00",
                            isOngoing: true,
                            stoneType: .WISDOM,
                            status: .PENDING
                        ),
                        DailyJourneyMapSchedule(
                            name: "수학 공부",
                            startTime: "14:00:00",
                            endTime: "15:00:00",
                            isOngoing: false,
                            stoneType: .GRIT,
                            status: .PENDING
                        )
                    ]
                )
                return vm
            }())
            .previewDisplayName("진행 중 일정 있음")
            
            // 2. 진행 중 없음 → 첫 PENDING 일정 하이라이팅 O
            DailyJourneyMapView(viewModel: {
                let vm = DailyJourneyMapViewModel()
                vm.scheduleData = DailyJourneyMapData(
                    scheduleCount: 3,
                    schedules: [
                        DailyJourneyMapSchedule(
                            name: "피아노 학원",
                            startTime: "08:00:00",
                            endTime: "09:30:00",
                            isOngoing: false,
                            stoneType: .COURAGE,
                            status: .COMPLETE
                        ),
                        DailyJourneyMapSchedule(
                            name: "영어 학원",
                            startTime: "14:00:00",
                            endTime: "15:30:00",
                            isOngoing: false,
                            stoneType: .WISDOM,
                            status: .PENDING
                        ),
                        DailyJourneyMapSchedule(
                            name: "수학 공부",
                            startTime: "16:00:00",
                            endTime: "17:00:00",
                            isOngoing: false,
                            stoneType: .GRIT,
                            status: .PENDING
                        )
                    ]
                )
                return vm
            }())
            .previewDisplayName("다음 일정 하이라이팅")
            
            // 3. 일정 없음
            DailyJourneyMapView(viewModel: {
                let vm = DailyJourneyMapViewModel()
                vm.scheduleData = DailyJourneyMapData(
                    scheduleCount: 0,
                    schedules: []
                )
                return vm
            }())
            .previewDisplayName("일정 없음 (Empty State)")
        }
    }
}
#endif
