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
        view.addSubviews(emptyView, missionView, floatingButton)
    }
    
    override func setLayout() {
        emptyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(102)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        missionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(102)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(115)
        }
    }
    
    private func setAction() {
        floatingButton.tapAction = { [weak self] in
            self?.showFloatingMenu()
        }
        
        missionView.onMissionTap = { [weak self] mission, dueAt in
            self?.presentMissionDetail(mission, dueAt: dueAt)
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
    
    private func presentMissionDetail(_ mission: MissionItemDTO, dueAt: String) {
        let detailData = DetailModel(
            title: mission.name,
            type: .mission(
                dueAt: dueAt,
                reward: mission.reward
            )
        )
        
        let bottomSheet = DetailBottomSheet(data: detailData)
        
        bottomSheet.onEditTap = { [weak self] in
            guard let self = self else { return }
            guard let editVC = self.diContainer.makeWriteMissionViewController() as? WriteMissionViewController else {
                return
            }

            editVC.configureEditMode(with: mission, dueAt: dueAt)
            
            NotificationCenter.default.post(name: .hideTabBar, object: true)
            NotificationCenter.default.post(name: .hideNavigationBar, object: true)
            
            editVC.modalPresentationStyle = .fullScreen
            bottomSheet.dismiss(animated: false) {
                self.present(editVC, animated: true)
            }
        }
        
        bottomSheet.onDeleteTap = { [weak self] in
            guard let self = self else { return }
            bottomSheet.dismiss(animated: false) {
                let dialog = DialogBox()
                dialog.configure(state: .deleteMission(title: mission.name, coin: "\(mission.reward)"))
                
                dialog.onTapCancel = { [weak self] in self?.dismiss(animated: false) }
                dialog.onTapClose = { [weak self] in self?.dismiss(animated: false) }
                
                dialog.onTapConfirm = { [weak self] in
                    guard let self = self else { return }
                    self.dismiss(animated: false)
                    self.viewModel?.deleteMission(id: mission.id)
                }
                
                let overlay = UIViewController()
                overlay.view.backgroundColor = .kBlack.withAlphaComponent(0.75)
                overlay.modalPresentationStyle = .overFullScreen
                overlay.view.addSubview(dialog)
                
                dialog.snp.makeConstraints {
                    $0.center.equalToSuperview()
                    $0.width.equalTo(343)
                }
                
                self.present(overlay, animated: false)
            }
        }
        
        self.present(bottomSheet, animated: false)
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
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func presentAddMissionByAI() {
        let vc = diContainer.makeAIMissionViewController()
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
