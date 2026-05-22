//
//  LogoutService.swift
//  Kiero
//
//  Created by 정윤아 on 3/6/26.
//

import Combine
import Foundation

protocol LogoutServiceType {
    func logout() -> AnyPublisher<Void, NetworkError>
}

final class LogoutService: LogoutServiceType {
    
    init() {}
    
    func logout() -> AnyPublisher<Void, NetworkError> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let _: BaseResponse<String?> = try await BaseService.shared.request(
                            endPoint: .logout
                        )
                        
                        TokenManager.shared.clearAll()
                        
                        promise(.success(()))
                    } catch let error as NetworkError {
                        if "\(error)".contains("noData") {
                            TokenManager.shared.clearAll()
                            promise(.success(()))
                        } else {
                            promise(.failure(error))
                        }
                    } catch {
                        if "\(error)".contains("noData") {
                            TokenManager.shared.clearAll()
                            promise(.success(()))
                        } else {
                            promise(.failure(.unknownError))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
