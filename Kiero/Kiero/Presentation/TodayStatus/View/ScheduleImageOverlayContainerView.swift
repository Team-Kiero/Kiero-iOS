//
//  ScheduleImageOverlayContainerView.swift
//  Kiero
//
//  Created by 안치욱 on 4/15/26.
//

import SwiftUI

struct ScheduleImageOverlayContainerView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let schedule: ScheduleItem
    @ObservedObject var viewModel: TodayStatusViewModel
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Color.kBlack.opacity(isVisible ? 0.75 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            ScheduleImageOverlayView(
                title: schedule.title,
                imageURL: viewModel.selectedScheduleImageURL,
                onClose: {
                    close()
                }
            )
            .padding(.horizontal, 16)
            .scaleEffect(isVisible ? 1.0 : 0.96)
            .opacity(isVisible ? 1.0 : 0.0)
        }
        .onAppear {
            viewModel.didTapScheduleCard(schedule)
            
            withAnimation(.easeInOut(duration: 0.2)) {
                isVisible = true
            }
        }
        .onDisappear {
            viewModel.selectedScheduleImageURL = nil
        }
    }
    
    private func close() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            NotificationCenter.default.post(name: .dimNavigationBar, object: false)
            viewModel.selectedScheduleImageURL = nil
            dismiss()
        }
    }
}
