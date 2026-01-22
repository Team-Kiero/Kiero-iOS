//
//  JourneyVerificationDTO.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/21/26.
//

import Foundation

enum JourneyVerificationDTO {
    struct PresignedURLRequest: Encodable {
        let fileName: String
        let contentType: String
    }
    
    struct PresignedResult: Decodable {
        let presignedUrl: String
        let fileName: String
    }
    
    struct CompleteRequest: Encodable {
        let imageUrl: String
    }
}
