//
//  MissionCompleteModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit

enum MissionCompleteModel: Int, CaseIterable {
    case courage = 0
    case grit
    case wisdom
    
    static func from(scheduleDetailId: Int) -> MissionCompleteModel {
        let index = (scheduleDetailId - 1) % 3
        return MissionCompleteModel(rawValue: index) ?? .courage
    }
    
    var name: String {
        switch self {
        case .courage: return "용기"
        case .grit: return "인내"
        case .wisdom: return "지혜"
        }
    }
    
    var image: UIImage {
        switch self {
        case .courage: return UIImage(resource: .ic3DBluestone)
        case .grit: return UIImage(resource: .ic3DRedstone)
        case .wisdom: return UIImage(resource: .ic3DGreenstone)
        }
    }
    
    var message: String {
        return "우와! \(self.name)의 불조각 을 손에 넣었어!"
    }
    
    var highlightKeyword: String {
        return "\(self.name)의 불조각"
    }
}

extension MissionCompleteModel {
    static func from(stoneType: StoneType) -> MissionCompleteModel {
        switch stoneType {
        case .courage: return .courage // 용기
        case .grit:    return .grit    // 인내
        case .wisdom:  return .wisdom  // 지혜
        }
    }
}
