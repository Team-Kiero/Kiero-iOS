//
//  ProfileCard.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI

struct ProfileCard: View {
    let name: String
    let date: String

    var body: some View {
        HStack (alignment: .top){
            VStack (alignment: .leading, spacing: 0){
                HStack (alignment: .bottom, spacing: 0){
                    Text(name)
                        .font(Font(UIFont.head2_20_B))
                        .foregroundColor(.white)
                    Text("의 오늘의 현황")
                        .font(Font(UIFont.head3_16_B))
                        .foregroundStyle(.white)
                }
                .frame(height: 24)
                .padding(.leading, 16)
                .padding(.top, 5)
                
                Text(date)
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(.gray500)
                    .padding(.leading, 18)
                    .padding(.top, 5.5)
            }
            
            Spacer()
            
            Image(.imgGoblinSmile)
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 96)
                .padding(.trailing, 40)
        }
    }
}
