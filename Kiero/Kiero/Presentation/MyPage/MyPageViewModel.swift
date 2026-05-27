//
//  MyPageViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import Combine
import SwiftUI
import UserNotifications

final class MyPageViewModel: BaseViewModel, ObservableObject {
    
    @Published var userName: String = ""
    @Published var userImage: String? = nil
    @Published var connectedChild: Int = 0
    
    @Published var isAlarmOn: Bool = false
    @Published var showNotificationDialog: Bool = false
    
    let scrollToTop = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        fetchUserInfo()
        fetchChildCount()
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
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func fetchChildCount() {
        ScheduleService.shared.fetchChildren()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("자녀 수 조회 실패: \(error)")
                }
            } receiveValue: { [weak self] children in
                self?.connectedChild = children.count
            }
            .store(in: &cancellables)
    }
    
    func fetchUserInfo() {
        userName = TokenManager.shared.getUserName() ?? ""
        userImage = TokenManager.shared.getProfile()
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.isAlarmOn = true
                    
                case .denied:
                    self.isAlarmOn = false
                    self.showNotificationDialog = true
                    
                case .notDetermined:
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            DispatchQueue.main.async {
                                self.isAlarmOn = granted
                                
                                if !granted {
                                    self.showNotificationDialog = true
                                }
                            }
                        }
                    
                @unknown default:
                    self.isAlarmOn = false
                    self.showNotificationDialog = true
                }
            }
        }
    }
    
    func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAlarmOn = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral
            }
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
