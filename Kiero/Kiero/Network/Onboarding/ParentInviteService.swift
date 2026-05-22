//
//  ParentInviteService.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import Foundation

protocol ParentInviteServiceType {
    func reissueInviteCode(
        childLastName: String,
        childFirstName: String
    ) async throws -> InviteCodeData
    
    func checkConnection(
        childLastName: String,
        childFirstName: String
    ) async throws -> ChildRegistrationStatusDTO
}

final class ParentInviteService: ParentInviteServiceType {
    init() {}

    func reissueInviteCode(
        childLastName: String,
        childFirstName: String
    ) async throws -> InviteCodeData {
        let request = InviteCodeRequest(
            childLastName: childLastName,
            childFirstName: childFirstName
        )

        return try await BaseService.shared.request(
            endPoint: .postInviteCode,
            body: request
        )
    }
    
    func checkConnection(
        childLastName: String,
        childFirstName: String
    ) async throws -> ChildRegistrationStatusDTO {
        try await BaseService.shared.request(
            endPoint: .checkConnection(
                lastName: childLastName,
                firstName: childFirstName
            )
        )
    }
}
