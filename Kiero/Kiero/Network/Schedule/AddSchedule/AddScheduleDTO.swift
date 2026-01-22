//
//  AddScheduleDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation

struct AddScheduleRequestDTO: Encodable {
    let name: String
    let isRecurring: Bool
    let startTime: String
    let endTime: String
    let scheduleColor: String
    let dayOfWeek: String?
    let dates: String?
}

struct DefaultColorResponseDTO: Decodable {
    let scheduleColor: String
    let colorCode: String
}
