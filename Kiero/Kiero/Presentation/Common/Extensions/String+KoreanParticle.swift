//
//  String+KoreanParticle.swift
//  Kiero
//
//  Created by 정윤아 on 1/15/26.
//

import Foundation

extension String {
    private var hasCoda: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = trimmed.last else { return false }
        guard let scalar = last.unicodeScalars.first else { return false }
        
        let value = scalar.value
        guard (0xAC00...0xD7A3).contains(value) else { return false }
        let index = value - 0xAC00
        return index % 28 != 0
    }
    
    // 이가 / 가
    var subjectMarker: String {
        hasCoda ? "이가" : "가"
    }
    
    // 은 / 는
    var topicMarker: String {
        hasCoda ? "은" : "는"
    }
    
    // 을 / 를
    var objectMarker: String {
        hasCoda ? "을" : "를"
    }
    
    // 아 / 야
    var vocativeMarker: String {
        hasCoda ? "아" : "야"
    }
}
