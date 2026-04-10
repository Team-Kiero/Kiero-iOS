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
    
    private let topInsetFromScreen: CGFloat = 105
    
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
            let screenHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
            let visibleTopInset = max(topInsetFromScreen - proxy.safeAreaInsets.top, 0)
            let sheetHeight = screenHeight - topInsetFromScreen
            
            ZStack(alignment: .bottom) {
                Color.kBlack.opacity(isVisible ? 0.75 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }
                
                MissionBottomSheet(
                    selectedTab: $selectedTab,
                    completeMissions: completeMissions,
                    incompleteMissions: incompleteMissions,
                    onClose: {
                        close()
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: sheetHeight,
                    maxHeight: sheetHeight,
                    alignment: .top
                )
                .offset(y: isVisible ? 0 : sheetHeight + 40)
            }
            .padding(.top, visibleTopInset)
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isVisible = true
                }
            }
        }
        .background(Color.clear)
    }
    
    private func close() {
        NotificationCenter.default.post(name: .hideTabBar, object: false)
        NotificationCenter.default.post(name: .dimNavigationBar, object: false)
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
        }
    }
}
