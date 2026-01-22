//
//  CoinMissionViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 1/13/26.
//

import Foundation
import Combine

final class CoinMissionViewModel: BaseViewModel, ViewModelType {
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewWillAppear: AnyPublisher<Void, Never>
        let completeMission: AnyPublisher<Int64, Never>
    }
    
    struct Output {
        let userInfo: AnyPublisher<ChildrenInfo,Never>
        let missions: AnyPublisher<[MissionGroupDTO], Never>
    }
    
    private let wishWellService: WishWellServiceType
    private let missionService: MissionServiceType
    private let coinMissionService: CoinMissionServiceType
    
    private let userInfoSubject =
    CurrentValueSubject<ChildrenInfo, Never>(
        .init(firstName: "", coinAmount: 0, today: "")
    )
    private let missionsSubject =
    CurrentValueSubject<[MissionGroupDTO], Never>([])
    
    init(
        wishWellService: WishWellServiceType = WishWellService(),
        missionService: MissionServiceType = MissionService(),
        coinMissionService: CoinMissionServiceType = CoinMissionService()
    ) {
        self.wishWellService = wishWellService
        self.missionService = missionService
        self.coinMissionService = coinMissionService
        super.init()
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .sink { [weak self] _ in
                self?.fetchUserInfo()
                self?.fetchMissions()
            }
            .store(in: &cancellables)
        
        input.viewWillAppear
            .sink { [weak self] _ in
                self?.fetchUserInfo()
                self?.fetchMissions()
            }
            .store(in: &cancellables)
        
        input.completeMission
            .flatMap { [weak self] missionId -> AnyPublisher<MissionCompleteResponseDTO, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.coinMissionService.completeMission(missionId: missionId)
                    .catch { error in
                        print("❌ 미션 완료 실패:", error)
                        return Empty<MissionCompleteResponseDTO, Never>()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] dto in
                self?.applyComplete(dto)
            }
            .store(in: &cancellables)
        
        return Output (
            userInfo: userInfoSubject.eraseToAnyPublisher(),
            missions: missionsSubject.eraseToAnyPublisher()
        )
    }
    
    private func fetchUserInfo() {
        wishWellService.fetchMyInfo()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] info in
                self?.userInfoSubject.send(info)
            })
            .store(in: &cancellables)
    }
    
    private func fetchMissions() {
        missionService.fetchMissions(childId: nil)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] dto in
                self?.missionsSubject.send(dto.missionsByDate)
            })
            .store(in: &cancellables)
    }
    
    private func applyComplete(_ dto: MissionCompleteResponseDTO) {
        var current = missionsSubject.value
        
        let completedId = Int(dto.id)
        
        for groupIdx in current.indices {
            if let missionIdx = current[groupIdx].missions.firstIndex(where: { $0.id == completedId }) {
                
                var updatedMissions = current[groupIdx].missions
                let old = updatedMissions[missionIdx]
                
                updatedMissions[missionIdx] = MissionItemDTO(
                    id: old.id,
                    name: old.name,
                    reward: old.reward,
                    isCompleted: true
                )
                
                let oldGroup = current[groupIdx]
                current[groupIdx] = MissionGroupDTO(
                    dueAt: oldGroup.dueAt,
                    dayOfWeek: oldGroup.dayOfWeek,
                    missions: updatedMissions
                )
                
                break
            }
        }
        
        missionsSubject.send(current)
        
        var user = userInfoSubject.value
        user = ChildrenInfo(
            firstName: user.firstName,
            coinAmount: user.coinAmount + dto.reward,
            today: user.today
        )
        userInfoSubject.send(user)
    }
}
