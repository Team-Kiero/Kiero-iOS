//
//  MissionViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class MissionViewController: BaseViewController<MissionViewModel> {
    
    var onAddMissionDirectlyTap: (() -> Void)?
    var onAddMissionByAITap: (() -> Void)?
    var onEditMissionTap: ((MissionItemDTO, String, DetailBottomSheet) -> Void)?
    
    private let emptyView = EmptyView(text: "등록된 미션이 없어요.\n우측 하단 버튼을 눌러 미션을 추가해보세요!")
    private let missionView = MissionView()
    private let floatingButton = FloatingButton(type: .mission)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.fetchMissions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAction()
    }

    override func setUI() {
        view.addSubviews(emptyView, missionView, floatingButton)
    }
    
    override func setLayout() {
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        missionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(110)
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
            switch index {
            case 0:
                self?.onAddMissionDirectlyTap?()
            case 1:
                self?.onAddMissionByAITap?()
            default:
                break
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
        
        let bottomSheet = DetailBottomSheet(
            data: detailData,
            showEditDelete: !mission.isCompleted
        )
        
        bottomSheet.onEditTap = { [weak self, weak bottomSheet] in
            guard let self, let bottomSheet else { return }
            self.onEditMissionTap?(mission, dueAt, bottomSheet)
        }
        
        bottomSheet.onDeleteTap = { [weak self, weak bottomSheet] in
            guard let self, let bottomSheet else { return }
            
            bottomSheet.dismiss(animated: false) {
                let dialog = DialogBox()
                dialog.configure(
                    state: .deleteMission(
                        title: mission.name,
                        coin: "\(mission.reward)"
                    )
                )
                
                dialog.onTapClose = { [weak self, weak dialog] in
                    guard let self, let dialog else { return }
                    dialog.dismiss()
                    self.present(bottomSheet, animated: false)
                }
                
                dialog.onTapCancel = { [weak self, weak dialog] in
                    guard let self, let dialog else { return }
                    dialog.dismiss()
                    self.present(bottomSheet, animated: false)
                }
                
                dialog.onTapConfirm = { [weak self, weak dialog] in
                    guard let self, let dialog else { return }
                    dialog.dismiss()
                    self.viewModel?.deleteMission(id: mission.id)
                }
                
                dialog.show(in: self)
            }
        }
        
        present(bottomSheet, animated: false)
    }
    
    override func bindViewModel() {
        viewModel?.$missionGroups
            .receive(on: RunLoop.main)
            .sink { [weak self] groups in
                guard let self else { return }
                
                let hasData = !groups.isEmpty
                self.emptyView.isHidden = hasData
                self.missionView.isHidden = !hasData
                
                if hasData {
                    self.missionView.updateMissionGroups(groups)
                }
            }
            .store(in: &cancellables)
    }
}
