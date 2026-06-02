//
//  RequiredTermsResponse.swift
//  Kiero
//
//  Created by 안치욱 on 5/29/26.
//

import Foundation

struct RequiredTermsAgreementStatusData: Codable {
    let isRequiredTermsAllAgreed: Bool
}

struct RequiredTerm: Codable {
    let termsId: Int
    let termsType: TermsType
    let url: String
}

enum TermsType: String, Codable {
    case privacyPolicy = "PRIVACY_POLICY"
    case serviceTerms = "SERVICE_TERMS"
}
