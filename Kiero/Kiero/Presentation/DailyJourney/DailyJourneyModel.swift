//
//  DailyJourneyModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import Foundation

struct DailyJourneyModel {
    enum ActionButtonType {
        case verify
        case lightFire
        case hidden 
    }
    
    let bubbleText: String
    let highlightKeywords: [String]
    let journeyTimeText: String
    let isMissionActive: Bool
    let kidName: String
    let dateText: String
    let coinCount: Int
    let fireStoneCount: Int
    let maxFireStoneCount: Int
    let scheduleOrder: Int
    let scheduleOrderText: String
    let speechFieldType: SpeechField.fieldType
    let chipItemType: ChipItem.ChipStyle
    let isTimeViewActive: Bool
    let actionButtonType: ActionButtonType
}
