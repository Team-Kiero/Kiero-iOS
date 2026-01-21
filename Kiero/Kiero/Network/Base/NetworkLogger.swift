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
    
    func logRequest(_ request: URLRequest) {
        let url = request.url?.absoluteString ?? "유효하지 않은 URL"
        let method = request.httpMethod ?? "unknown method"
        
        var log = "\n----------------------------------------------------\n"
        log.append("1️⃣ [\(method)] \(url)\n")
        log.append("----------------------------------------------------\n")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            log.append("header: \(headers)\n")
        }
        
        if let body = request.httpBody, let bodyString = prettyPrintJSON(data: body) {
            log.append("body: \n\(bodyString)\n")
        }
        
        log.append("------------------- END \(method) -------------------\n")
        print(log)
    }

    
    func responseLog(_ response: HTTPURLResponse, data: Data) {
        let url = response.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        
        var log = "------------------- 네트워크 통신 결과 -------------------"
        log.append("\n3️⃣ [\(statusCode)] \(url)\n")
        log.append("----------------------------------------------------\n")
        log.append("response: \n")
        
        if let reString = prettyPrintJSON(data: data) {
            log.append("4️⃣ \(reString)\n")
        }
        
        log.append("------------------- END HTTP -------------------\n")
        print(log)
    }
    
    private func prettyPrintJSON(data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8)
        }
        return prettyString
    }
}
