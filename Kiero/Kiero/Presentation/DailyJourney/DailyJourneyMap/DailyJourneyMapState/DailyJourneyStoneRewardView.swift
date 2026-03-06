//
//  DailyJourneyStoneRewardView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

struct DailyJourneyStoneRewardView: View {
    let stoneType: String
    let status: String
    
    private var stoneImageName: String {
        switch stoneType {
        case "COURAGE": 
            return "ic_3d_bluestone"
        case "GRIT":    
            return "ic_3d_redstone"
        case "WISDOM":  
            return "ic_3d_greenstone"
        default:        
            return "ic_3d_bluestone"
        }
    }
    
    private var ringColor: Color {
        switch status {
        case "COMPLETE", "VERIFIED":
            return .main
        case "FAILED", "SKIPPED":
            return .point
        default:
            return .white
        }
    }
    
    private var hasGlow: Bool {
        status == "COMPLETE" || status == "VERIFIED" || status == "FAILED" || status == "SKIPPED"
    }
    
    private var resultText: String? {
        switch status {
        case "COMPLETE", "VERIFIED": 
            return "획득!"
        case "FAILED", "SKIPPED":    
            return "실패!"
        default:
            return nil
        }
    }
    
    private var resultColor: Color {
        switch status {
        case "COMPLETE", "VERIFIED":
            return .main
        case "FAILED", "SKIPPED":
            return .point
        default:
            return .clear
        }
    }
    
    var body: some View {
        ringView
            .frame(width: 30, height: 30)
            .overlay(alignment: .bottom) {
                if let text = resultText {
                    Text(text)
                        .font(Font(UIFont.body6_10_R))
                        .foregroundStyle(resultColor)
                        .offset(y: 18) 
                        .fixedSize()
                }
            }
    }
    
    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(ringColor, lineWidth: 2)
                .shadow(color: hasGlow ? ringColor : .clear, radius: 4)
                .shadow(color: hasGlow ? ringColor.opacity(0.5) : .clear, radius: 8)
            
            Image(stoneImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
}
