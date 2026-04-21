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
    
    private let topSpacingFromSafeArea: CGFloat = 57
    
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
            let sheetTop = proxy.safeAreaInsets.top + topSpacingFromSafeArea
            
            ZStack(alignment: .top) {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }
                
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: sheetTop)
                    
                    MissionBottomSheet(
                        selectedTab: $selectedTab,
                        completeMissions: completeMissions,
                        incompleteMissions: incompleteMissions,
                        onClose: {
                            close()
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .offset(y: isVisible ? 0 : proxy.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .bottom)
            }
            .ignoresSafeArea()
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
