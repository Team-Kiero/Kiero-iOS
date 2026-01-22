//
//  MissionCompleteModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit

enum MissionCompleteModel: String, CaseIterable {
    case courage = "COURAGE"
    case grit = "GRIT"
    case wisdom = "WISDOM"
    
    static func from(stoneType: StoneType) -> MissionCompleteModel {
        switch stoneType {
        case .courage: return .courage
        case .grit:    return .grit
        case .wisdom:  return .wisdom
        }
    }
    
    static func from(serverStrings: [String]) -> [MissionCompleteModel] {
        return serverStrings.compactMap { MissionCompleteModel(rawValue: $0) }
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
    
    func getMessage() -> String {
        return "우와! \(self.name)의 불조각을 손에 넣었어!"
    }
    
    var highlightKeyword: String {
        return "\(self.name)의 불조각"
    }
}
