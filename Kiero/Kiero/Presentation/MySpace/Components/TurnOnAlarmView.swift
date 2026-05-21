//
//  TurnOnAlarmView.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? .main : .gray800)
                .frame(width: 46, height: 29)

            Circle()
                .fill(.white)
                .frame(width: 22, height: 22)
                .padding(3.5)
        }
        .animation(.easeInOut(duration: 0.2), value: isOn)
        .onTapGesture { isOn.toggle() }
    }
}

struct TurnOnAlarmView: View {
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("알림 켜기")
                    .font(Font(UIFont.title3_16_SB))
                    .foregroundStyle(.white)

                Text("진행되는 여정에 대한 알림을 받을 수 있어!")
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(.gray400)
            }

            Spacer()

            CustomToggle(isOn: $isOn)
        }
        .padding(12)
        .background(.gray900, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    @Previewable @State var isOn = true
    TurnOnAlarmView(isOn: $isOn)
        .padding()
        .background(.kBlack)
}
