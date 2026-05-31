//
//  DeleteAccountViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 5/31/26.
//

import Combine
import Foundation

enum DeleteAccountRoute {
    case pickRole
    case toast(String)
}

final class DeleteAccountViewModel: BaseViewModel, ObservableObject {
    
    @Published var isLoading = false
    
    private let routeSubject = PassthroughSubject<DeleteAccountRoute, Never>()
    var route: AnyPublisher<DeleteAccountRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }
    
    func deleteAccount() {
        guard isLoading == false else { return }
        
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let _: EmptyResponse = try await BaseService.shared.request(
                    endPoint: .deleteParentAccount
                )
                
                await MainActor.run {
                    self.isLoading = false
                    TokenManager.shared.clearAll()
                    self.routeSubject.send(.pickRole)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.routeSubject.send(.toast("회원 탈퇴에 실패했습니다."))
                }
            }
        }
    }
}
