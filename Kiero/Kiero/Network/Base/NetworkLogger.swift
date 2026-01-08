//
//  NetworkLogger.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

final class NetworkLogger {
    static let shared = NetworkLogger()
    private init() { }
    
    func responseLog(_ response: HTTPURLResponse, data: Data) {
        print("Response")
        print("Status Code: \(response.statusCode)")
        print("Headers: \(response.allHeaderFields)")
        
        if let responseBody = String(data: data, encoding: .utf8) {
            print("Body: \(responseBody)")
        } else {
            print("Body is not UTF-8 decodable")
        }
        
        print("===========================")
    }
}
