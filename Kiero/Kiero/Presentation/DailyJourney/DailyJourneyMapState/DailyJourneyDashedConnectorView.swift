//
//  DailyJourneyDashedConnectorView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

struct DailyJourneyDashedConnectorView: View {
    let isOngoing: Bool
    let status: String
    
    private var shouldShow: Bool {
        isOngoing || status == "PENDING"
    }
    
    var body: some View {
        Group {
            if shouldShow {
                SymmetricalDashedLine(color: Color.gray500)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 1)
        .padding(.horizontal, 20)
    }
}

struct SymmetricalDashedLine: View {
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            let dashWidth: CGFloat = 4
            let endDashWidth: CGFloat = 2
            let targetGap: CGFloat = 3
            
            let availableWidth = width - (endDashWidth * 2) - targetGap
            let n = max(0, Int(availableWidth / (dashWidth + targetGap)))
            
            let totalDashWidth = (endDashWidth * 2) + (dashWidth * CGFloat(n))
            let exactGap = (width - totalDashWidth) / CGFloat(n + 1)
            
            HStack(spacing: exactGap) {
                Rectangle()
                    .fill(color)
                    .frame(width: endDashWidth, height: 1)
                
                ForEach(0..<n, id: \.self) { _ in
                    Rectangle()
                        .fill(color)
                        .frame(width: dashWidth, height: 1)
                }
                
                Rectangle()
                    .fill(color)
                    .frame(width: endDashWidth, height: 1)
            }
        }
        .frame(height: 1)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kBlack
        
        VStack(spacing: 40) {
            DailyJourneyDashedConnectorView(
                isOngoing: true,
                status: "COMPLETE"
            )
        }
    }
}
