//
//  MissionViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit
import Combine

import SnapKit
import Then

final class MissionViewController: BaseViewController<MissionViewModel> {
    
    // MARK: - UI Components
    
    private lazy var navigationBar = NavigationBar(type: .main(title: "미션")).then {
        $0.rightButtonAction = { [weak self] in
            self?.presentNotificationFeed()
        }
    }
    
    private let emptyView = EmptyView(text: "등록된 미션이 없어요.\n우측 하단 버튼을 눌러 미션을 추가해보세요!")
    private let missionView = MissionView()
    
    private let floatingButton = FloatingButton(type: .mission)
    
    // MARK: - Life Cycle
    
    public override init(viewModel: MissionViewModel, diContainer: any ViewControllerFactory) {
        super.init(viewModel: viewModel, diContainer: diContainer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.fetchMissions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAction()
    }
    
    // MARK: - Setup Methods

    override func setUI() {
        view.addSubviews(navigationBar, emptyView, missionView, floatingButton)
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(57)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        missionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(31)
            $0.bottom.equalToSuperview().inset(119)
        }
    }
    
    private func setAction() {
        floatingButton.tapAction = { [weak self] in
            self?.showFloatingMenu()
        }
    }
    
    private func showFloatingMenu() {
        guard let window = view.window else { return }
        let menuView = MissionFloatingMenuView()
        
        menuView.onMenuSelected = { [weak self] index in
            guard let self = self else { return }
            switch index {
            case 0: self.presentAddMissionDirectly()
            case 1: self.presentAddMissionByAI()
            default: break
            }
        }
        
        menuView.show(in: window)
        window.bringSubviewToFront(floatingButton)
    }
    
    override func bindViewModel() {
        viewModel?.$missionGroups
            .receive(on: RunLoop.main)
            .sink { [weak self] groups in
                guard let self = self else { return }
                
                let hasData = !groups.isEmpty
                self.emptyView.isHidden = hasData
                self.missionView.isHidden = !hasData
                
                if hasData {
                    self.missionView.updateMissionGroups(groups)
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentNotificationFeed() {
        let notificationVC = diContainer.makeNotificationFeedViewController()
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    private func presentAddMissionDirectly() {
        let vc = diContainer.makeWriteMissionViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentAddMissionByAI() {
        let vc = diContainer.makeAIMissionViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
