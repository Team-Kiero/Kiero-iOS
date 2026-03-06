//
//  RewardEditView.swift
//  Kiero
//
//  Created by 정윤아 on 3/4/26.
//

import SwiftUI

enum RewardMode {
    case add
    case edit(Reward)
    
    var title: String {
        switch self {
        case .add: return "보상 추가"
        case .edit: return "보상 수정"
        }
    }
}

struct RewardEditView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isCoinFieldFocused: Bool
    
    var mode: RewardMode
    var onSave: (String, Int) -> Void
    
    @State private var rewardTitle: String = ""
    @State private var coinCount: Int = 20
    
    init(mode: RewardMode, onSave: @escaping (String, Int) -> Void) {
        self.mode = mode
        self.onSave = onSave
        if case let .edit(reward) = mode {
            _rewardTitle = State(initialValue: reward.title)
            _coinCount = State(initialValue: reward.cost)
        }
    }
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                NavigationBarWrapper(type: .closeDone(title: mode.title),
                                     onLeftTap: { dismiss() },
                                     onRightTap: { saveAction() }
                )
                .frame(height: 37)
                .padding(.bottom, 25)
                .padding(.top, 13)
                
                SwiftUI.TextField("",
                                  text: $rewardTitle,
                                  prompt: Text("보상 이름을 입력해주세요.")
                    .foregroundStyle(.gray500)
                    .font(Font(UIFont.body1_18_R))
                )
                .focused($isTextFieldFocused)
                .foregroundStyle(.white)
                .padding(.leading, 16)
                .padding(.vertical, 9)
                .padding(.bottom, 15)
                .onChange(of: rewardTitle) { newValue in
                    if newValue.count > 15 {
                        rewardTitle = String(newValue.prefix(15))
                    }
                }
                
                HStack(spacing: 4) {
                    Image(.ic3DCoin)
                    
                    Text("보상")
                        .font(Font(UIFont.body2_16_R))
                        .foregroundStyle(.white)
                }
                .padding(.leading, 16)
                .padding(.vertical, 11.5)
                .padding(.bottom, 12)
                
                HStack(spacing: 10) {
                    CoinAddButton(label: "-10") {
                        adjustCoin(-10)
                    }
                    CoinAddButton(label: "-5") {
                        adjustCoin(-5)
                    }
                    VStack(spacing: 11) {
                        SwiftUI.TextField("", text: Binding(
                            get: { "\(coinCount)" },
                            set: { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if let num = Int(filtered) {
                                    coinCount = num
                                } else if filtered.isEmpty {
                                    coinCount = 0
                                }
                            }
                        ))
                        .focused($isCoinFieldFocused)
                        .font(Font(UIFont.title3_16_SB))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .frame(minWidth: 60)
                        .onChange(of: isCoinFieldFocused) { isFocused in
                            if !isFocused {
                                validateCoinRange()
                            }
                        }
                        
                        Rectangle()
                            .fill(Color.gray800)
                            .frame(width: 76, height: 1)
                    }
                    .padding(.horizontal, 5.5)
                    .fixedSize()
                    
                    CoinAddButton(label: "+5") {
                        adjustCoin(5)
                    }
                    CoinAddButton(label: "+10") {
                        adjustCoin(10)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
            isCoinFieldFocused = false}
    }
    
    private func validateCoinRange() {
        if coinCount > 500 {
            coinCount = 500
            Toast.show(message: "최대 보상은 500개입니다")
        } else if coinCount < 1 {
            coinCount = 1
            Toast.show(message: "보상을 입력해주세요.")
        }
    }
    
    private func adjustCoin(_ amount: Int) {
        let newValue = coinCount + amount
        coinCount = newValue
        
        if coinCount < 1 {
            Toast.show(message: "보상을 입력해주세요.")
            coinCount = 1
            return
        }
        
        if coinCount > 500 {
            Toast.show(message: "최대 보상은 500개입니다")
            coinCount = 500
        }
    }
    
    private func saveAction() {
        if rewardTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            Toast.show(message: "보상 이름을 입력해주세요.")
            return
        }
        
        onSave(rewardTitle, coinCount)
        
        switch mode {
        case .add:
            Toast.show(message: "쿠폰이 등록되었습니다.")
            // TODO: 신규 등록 API 호출
        case .edit(_):
            Toast.show(message: "미션이 수정되었습니다.")
            // TODO: 수정 API 호출
        }
        dismiss()
    }
}

struct CoinAddButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Font(UIFont.title3_16_SB))
                .foregroundStyle(.gray500)
        }
        .frame(width: 54, height: 45)
        .background(.gray900)
        .cornerRadius(15)
    }
}
