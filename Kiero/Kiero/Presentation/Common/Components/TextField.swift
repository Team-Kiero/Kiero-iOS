//
//  TextField.swift
//  Kiero
//
//  Created by 안치욱 on 1/12/26.
//

import UIKit

enum UserRole {
    case parent(ParentField)
    case child(ChildField)

    enum ParentField { case lastName, firstName }
    enum ChildField { case lastName, firstName, inviteCode }
}

extension UserRole {
    var title: String {
        switch self {
        case .parent(.lastName): return "아이의 성을 입력해주세요."
        case .parent(.firstName): return "아이의 이름을 입력해주세요."
        case .child(.lastName): return "성"
        case .child(.firstName): return "이름"
        case .child(.inviteCode): return "초대 코드"
        }
    }

    var placeholder: String {
        switch self {
        case .parent(.lastName): return "성"
        case .parent(.firstName): return "이름"
        case .child(.lastName): return "성을 입력해줘!"
        case .child(.firstName): return "이름을 입력해줘!"
        case .child(.inviteCode): return "부모님께 받은 비밀 암호 6자리를 입력해줘!"
        }
    }

    var regex: String {
        switch self {
        case .parent(.lastName), .child(.lastName):
            return "^[가-힣]{1,2}$"
        case .parent(.firstName), .child(.firstName):
            return "^[가-힣]{1,5}$"
        case .child(.inviteCode):
            return "^[A-Za-z0-9]{6,10}$"
        }
    }

    var errorMessage: String {
        switch self {
        case .parent(.lastName), .child(.lastName):
            return "특수문자, 이모지, 공백을 포함하지 않은 이름을 입력해주세요"
        case .parent(.firstName), .child(.firstName):
            return "이름은 한글로 입력해주세요."
        case .child(.inviteCode):
            return "초대코드는 영문/숫자 6~10자입니다."
        }
    }
}

final class TextField: UIView {
    
}
