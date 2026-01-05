//
//  UIFont+.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/5/26.
//

import UIKit

enum NotoSansWeight: String{
    case regular = "Regular"
    case semibold = "SemiBold"
    case bold = "Bold"
    
    var systemWeight: UIFont.Weight {
        switch self {
        case .regular:
            return .regular
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }
}

extension UIFont {
    static func notosans(_ weight: NotoSansWeight = .regular, size: CGFloat) -> UIFont{
        let name = "NotoSansKR-\(weight.rawValue)"
        if let custom = UIFont(name: name, size: size) {
            return custom
        }
        return .systemFont(ofSize: size, weight: weight.systemWeight)
    }
    
    enum NotoSans {
        case head1_22_B
        case head2_20_B
        case head3_16_B
        case head4_14_B
        
        case title1_22_SB
        case title2_20_SB
        case title3_16_SB
        case title4_14_SB
        
        case body1_18_R
        case body2_16_R
        case body3_14_R
        case body4_12_R
        case body5_10_R
        
        var weight: NotoSansWeight {
            switch self {
            case .head1_22_B, .head2_20_B, .head3_16_B, .head4_14_B:
                return .bold
            case .title1_22_SB, .title2_20_SB, .title3_16_SB, .title4_14_SB:
                return .semibold
            case .body1_18_R, .body2_16_R, .body3_14_R, .body4_12_R, .body5_10_R:
                return .regular
            }
        }
        
        var size: CGFloat {
            switch self {
            case .head1_22_B, .title1_22_SB:   return 22
            case .head2_20_B, .title2_20_SB:   return 20
            case .body1_18_R:  return 18
            case .head3_16_B, .title3_16_SB, .body2_16_R:    return 16
            case .head4_14_B, .title4_14_SB, .body3_14_R:    return 14
            case .body4_12_R:   return 12
            case .body5_10_R:   return 10
            }
        }
        
        var font: UIFont {
            .notosans(weight, size: size)
        }
        
        var letterSpacingPercent: CGFloat {
            switch self {
            case .body1_18_R, .body2_16_R, .body3_14_R, .body4_12_R, .body5_10_R:
                return -0.5
            default:
                return -1.0
            }
        }
        
        var lineHeightPercent: CGFloat {
            switch self {
            case .body1_18_R, .body2_16_R, .body3_14_R, .body4_12_R, .body5_10_R:
                return 130
            default:
                return 140
            }
        }
    }
    
    static var head1_22_B: UIFont { NotoSans.head1_22_B.font }
    static var head2_20_B: UIFont { NotoSans.head2_20_B.font }
    static var head3_16_B: UIFont { NotoSans.head3_16_B.font }
    static var head4_14_B: UIFont { NotoSans.head4_14_B.font }
    
    static var title1_22_SB: UIFont { NotoSans.title1_22_SB.font }
    static var title2_20_SB: UIFont { NotoSans.title2_20_SB.font }
    static var title3_16_SB: UIFont { NotoSans.title3_16_SB.font }
    static var title4_14_SB: UIFont { NotoSans.title4_14_SB.font }
    
    static var body1_18_R: UIFont { NotoSans.body1_18_R.font }
    static var body2_16_R: UIFont { NotoSans.body2_16_R.font }
    static var body3_14_R: UIFont { NotoSans.body3_14_R.font }
    static var body4_12_R: UIFont { NotoSans.body4_12_R.font }
    static var body5_10_R: UIFont { NotoSans.body5_10_R.font }
}
