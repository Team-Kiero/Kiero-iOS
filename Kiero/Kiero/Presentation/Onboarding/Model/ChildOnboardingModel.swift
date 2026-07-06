//
//  ChildOnboardingModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/17/26.
//

import UIKit

struct SpeechItem {
    let image: UIImage
    let name: String
    let lines: [String]
    let highlightKeywords: [String]
}

enum ChildOnboardingScript {
    static let items: [SpeechItem] = [
        .init(image: .imgStory1, name: "꾸비", lines: ["드디어 만났다! 나의 짝꿍 {userName}", "난 꼬마 히어로 꾸비야. 우리 같이 모험을 떠나볼까?"], highlightKeywords: []),
        .init(image: .imgStory2, name: "꾸비", lines: ["다른 도깨비들은 장난치는 걸 좋아하지만,", "난 '영웅의 불씨'를 품고 태어난 특별한 도깨비야!", "너의 노력을 멋진 소원으로 바꾸는 꼬마 히어로 지"], highlightKeywords: ["꼬마 히어로"]),
        .init(image: .imgStory3, name: "꾸비", lines: ["그런데 큰일이야...", "배에 있는 ‘영웅의 불씨'가 자꾸 꺼지려고 해.", "나 혼자서는 지킬 수 없거든", "오직 너만이 이 불씨를 다시 키울 수 있어!"], highlightKeywords: ["오직 너만이 이 불씨를 다시 키울 수 있어!"]),
        .init(image: .imgStory4, name: "꾸비", lines: ["오늘의 여정을 따라 하루를 보내고", "불조각을 나에게 건네줘!", "너가 준 [용기, 인내, 지혜의 불조각] 이", "내 마음의 불꽃을 키워줄거야."], highlightKeywords: ["[용기, 인내, 지혜의 불조각]"]),
        .init(image: .imgStory5, name: "꾸비", lines: ["그 힘으로 내가 반짝이는 금화를 만들어줄게!", "소원의 우물에서 금화를 통해", "너의 소원을 이룰 수 있을거야!"], highlightKeywords: [])
    ]
}
