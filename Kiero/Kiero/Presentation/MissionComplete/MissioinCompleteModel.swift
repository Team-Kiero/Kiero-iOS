//
//  MissioinCompleteModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit

enum MissioinCompleteModel: Int, CaseIterable {
    case courage = 0
    case patience
    case wisdom
    
    static func from(scheduleDetailId: Int) -> MissioinCompleteModel {
        let index = (scheduleDetailId - 1) % 3
        return MissioinCompleteModel(rawValue: index) ?? .courage
    }
    
    var name: String {
        switch self {
        case .courage: return "용기"
        case .patience: return "인내"
        case .wisdom: return "지혜"
        }
    }
    
    var image: UIImage {
        switch self {
        case .courage: return UIImage(resource: .ic3DBluestone)
        case .patience: return UIImage(resource: .ic3DRedstone)
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
