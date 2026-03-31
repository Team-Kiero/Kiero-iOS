//
//  MissionBottomSheetContainerView.swift
//  Kiero
//
//  Created by 안치욱 on 3/30/26.
//

import SwiftUI

struct MissionBottomSheetContainerView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: MissionTab
    @State private var isVisible = false
    
    let completeMissions: [MissionItem]
    let incompleteMissions: [MissionItem]
    
    init(
        selectedTab: MissionTab,
        completeMissions: [MissionItem],
        incompleteMissions: [MissionItem]
    ) {
        _selectedTab = State(initialValue: selectedTab)
        self.completeMissions = completeMissions
        self.incompleteMissions = incompleteMissions
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.kBlack.opacity(isVisible ? 0.75 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }
                
                VStack {
                    Spacer()
                    
                    MissionBottomSheet(
                        selectedTab: $selectedTab,
                        isPresented: .constant(true),
                        completeMissions: completeMissions,
                        incompleteMissions: incompleteMissions,
                        onClose: {
                            close()
                        }
                    )
                    .offset(y: isVisible ? 0 : proxy.size.height + 20)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isVisible = true
                }
            }
        }
        .background(Color.clear)
    }
    
    private func close() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
            NotificationCenter.default.post(name: .hideTabBar, object: false)
            NotificationCenter.default.post(name: .dimNavigationBar, object: false)
        }
    }
}
