//
//  LogoutService.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import Combine
import Foundation

final class LogoutService {
    static let shared = LogoutService()
    private init() {}
    
    func logout() -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let _: BaseResponse<String?> = try await BaseService.shared.request(endPoint: .logout)
                        
                        TokenManager.shared.clearAll()
                        
                        promise(.success(()))
                    } catch {
                        if "\(error)".contains("noData") {
                            TokenManager.shared.clearAll()
                            promise(.success(()))
                        } else {
                            promise(.failure(error))
                        }
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
}
