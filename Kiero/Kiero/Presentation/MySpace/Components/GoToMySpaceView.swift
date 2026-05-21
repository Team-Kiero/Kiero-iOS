//
//  GoToMySpaceView.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import SwiftUI

struct GoToMySpaceView: View {
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Image(.icStarRound)
                            .resizable()
                            .frame(width: 18, height: 18)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.main, lineWidth: 0.75)
                            )
                        
                        Text("소원의 공간")
                            .font(Font(UIFont.title3_16_SB))
                            .foregroundStyle(.white)
                    }
                    
                    Text("내가 빌었던 소원들을 모아볼 수 있어!")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundStyle(.gray400)
                }
                
                Spacer()
                
                Image(.icRight)
                    .foregroundStyle(.gray400)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 20)
            .background(.gray900, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray700, lineWidth: 1)
            )
        }
    }
}
