//
//  MenuListItem.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import SwiftUI

struct MenuListItem: View {
    let title: String
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                Text(title)
                    .font(Font(UIFont.body3_14_R))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(.icRight)
                    .foregroundStyle(.gray400)
            }
            .frame(height: 48)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        MenuListItem(title: "키어로 이용 약속")
        MenuListItem(title: "키어로 나가기")
    }
    .padding()
    .background(.kBlack)
}
