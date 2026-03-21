//
//  MissionButtonBar.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI

struct MissionButtonBar: View {
    let completeCount: Int
    let incompleteCount: Int
    let completeAction: () -> Void
    let incompleteAction: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: completeAction) {
                MissionButtonContent(
                    title: "완료 미션",
                    count: completeCount
                )
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(width: 1, height: 45)
                .overlay(Color.gray800)
            
            Button(action: incompleteAction) {
                MissionButtonContent(
                    title: "미완료 미션",
                    count: incompleteCount
                )
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 71)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.kBlack)
                .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 3)
        }
    }
}

private struct MissionButtonContent: View {
    let title: String
    let count: Int

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(Font(UIFont.body5_11_R))
                .foregroundStyle(.gray500)

            Text("\(count)개")
                .font(Font(UIFont.title4_14_SB))
                .foregroundStyle(.white)
                .padding(.leading, 10)

            Image(.icRight)
                .renderingMode(.template)
                .foregroundStyle(.white)
        }
        .frame(height: 40)
    }
}
