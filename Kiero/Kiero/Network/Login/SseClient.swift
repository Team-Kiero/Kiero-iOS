//
//  SseClient.swift
//  Kiero
//
//  Created by 안치욱 on 1/22/26.
//

import Foundation

final class SseClient: NSObject {

    private let url: URL
    private let tokenProvider: () -> String?
    private let onEvent: (SseEventPayload) -> Void
    private let onError: (Error) -> Void

    private var session: URLSession!
    private var task: URLSessionDataTask?
    private var buffer = ""

    init(
        url: URL,
        tokenProvider: @escaping () -> String?,
        onEvent: @escaping (SseEventPayload) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.url = url
        self.tokenProvider = tokenProvider
        self.onEvent = onEvent
        self.onError = onError
        super.init()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = .infinity
        config.timeoutIntervalForResource = .infinity
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func connect() {
        disconnect()

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        req.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        if let token = tokenProvider() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("🌐 [SSEClient] CONNECT URL:", req.url?.absoluteString ?? "nil")
        print("🌐 [SSEClient] HEADERS:", req.allHTTPHeaderFields ?? [:])

        buffer = ""
        task = session.dataTask(with: req)
        task?.resume()
        
        print("🌐 [SSEClient] task resume called")
    }

    func disconnect() {
        task?.cancel()
        task = nil
        buffer = ""
    }

    private func handleChunk(_ data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer += chunk

        while true {
            if let r = buffer.range(of: "\r\n\r\n") {
                let block = String(buffer[..<r.lowerBound])
                buffer.removeSubrange(..<r.upperBound)
                parseEventBlock(block)
                continue
            }
            if let r = buffer.range(of: "\n\n") {
                let block = String(buffer[..<r.lowerBound])
                buffer.removeSubrange(..<r.upperBound)
                parseEventBlock(block)
                continue
            }
            break
        }
    }
    
    private func parseEventBlock(_ block: String) {
        let normalized = block.replacingOccurrences(of: "\r\n", with: "\n")

        var eventName: String?
        var dataLines: [String] = []

        for line in normalized.split(separator: "\n").map(String.init) {
            if line.hasPrefix("event:") {
                eventName = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("data:") {
                let v = line.dropFirst("data:".count).trimmingCharacters(in: .whitespaces)
                dataLines.append(v)
            } else {

            }
        }

        guard !dataLines.isEmpty else { return }

        let dataString = dataLines.joined(separator: "\n")

        let trimmed = dataString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.hasPrefix("{") {
            return
        }

        guard let jsonData = trimmed.data(using: .utf8) else { return }

        do {
            let payload = try JSONDecoder().decode(SseEventPayload.self, from: jsonData)
            onEvent(payload)
        } catch {
            onError(error)
        }
    }
}

extension SseClient: URLSessionDataDelegate {
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let http = response as? HTTPURLResponse {
            print("✅ [SSEClient] RESPONSE status:", http.statusCode)
            print("✅ [SSEClient] RESPONSE headers:", http.allHeaderFields)
        } else {
            print("✅ [SSEClient] RESPONSE non-http:", response)
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("📥 [SSEClient] RAW CHUNK:", String(data: data, encoding: .utf8) ?? "nil")
        handleChunk(data)
    }
}
