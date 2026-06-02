//
//  ExternalLinkDTO.swift
//  Kiero
//
//  Created by 안치욱 on 5/31/26.
//

import Foundation

struct ExternalLinkDTO: Codable {
    let linkType: ExternalLinkType
    let link: String
}

enum ExternalLinkType: String, Codable {
    case privacyPolicy = "PRIVACY_POLICY"
    case serviceTerms = "SERVICE_TERMS"
    case openSourceLicense = "OPENSOURCE_LICENSE"
    case customerSupport = "CUSTOMER_SUPPORT"
}
