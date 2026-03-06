//
//  MyPageViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import Combine
import SwiftUI

final class MyPageViewModel: BaseViewModel, ObservableObject {
    
    @Published var userName: String = ""
    @Published var userImage: String? = nil
    @Published var connectedChild: Int = 0
    
    let scrollToTop = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        fetchUserInfo()
    }
    
    func requestLogout() {
            LogoutService.shared.logout()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("로그아웃 완료")
                        LogoutHelper.logoutToPickRole()
                    case .failure(let error):
                        print("로그아웃 실패: \(error)")
                        LogoutHelper.logoutToPickRole()
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    
    func fetchUserInfo() {
        self.userName = TokenManager.shared.getUserName() ?? ""
        self.userImage = TokenManager.shared.getProfile()
    }
}
