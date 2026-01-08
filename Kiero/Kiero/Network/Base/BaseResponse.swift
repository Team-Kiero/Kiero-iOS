//
//  BaseResponse.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let status: Int
    let message: String
    let data: T?
}

struct EmptyResponse: Decodable { }
