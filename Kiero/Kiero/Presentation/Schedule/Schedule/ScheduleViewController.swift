//
//  ScheduleViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import UIKit
import Combine
import SnapKit
import Then

class ScheduleViewController: BaseViewController<ScheduleViewModel> {
    
    // MARK: - Properties
    
    private var currentTabIndex: Int = 0 {
        didSet {
            updateFloatingButtonType()
        }
    }
    
    private let scheduleChildVC = AppDIContainer.shared.makeScheduleChildViewController()
    private let missionVC = AppDIContainer.shared.makeMissionViewController()
    
    // MARK: - UI Components
    
    private lazy var segmentedControl = SegmentedControl(
        titles: ["일정", "미션"],
        contentViews: [scheduleChildVC.view, missionVC.view]
    ).then {
        $0.onIndexChanged = { [weak self] index in
            self?.currentTabIndex = index
        }
    }
    
    private let floatingButton = FloatingButton(type: .schedule)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAction()
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        view.backgroundColor = .gray900
    }
    
    override func setUI() {
        addChild(scheduleChildVC)
        addChild(missionVC)
        
        view.addSubviews(segmentedControl, floatingButton)
        
        scheduleChildVC.didMove(toParent: self)
        missionVC.didMove(toParent: self)
    }
    
    override func setLayout() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(93)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(31)
            $0.bottom.equalToSuperview().inset(119)
        }
    }
    
    private func setAction() {
        floatingButton.tapAction = { [weak self] in
            guard let self = self else { return }
            
            if self.currentTabIndex == 0 {
                self.presentAddSchedule()
            } else {
                self.presentAddMission()
            }
        }
    }
    
    private func updateFloatingButtonType() {
        let newType: FloatingButtonType = (currentTabIndex == 0) ? .schedule : .mission
        floatingButton.updateType(newType)
    }
    
    private func presentAddSchedule() {
        let addScheduleVC = AppDIContainer.shared.makeAddScheduleViewController()
        let nav = UINavigationController(rootViewController: addScheduleVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    private func presentAddMission() {
        let menuView = MissionFloatingMenuView()
        
        menuView.onMenuSelected = { [weak self] index in
            guard self != nil else { return }
            
            if index == 0 {
//                let directVC = self.diContainer.makeDirectMissionAddViewController()
//                self.navigationController?.pushViewController(directVC, animated: true)
            } else {
//                let aiVC = self.diContainer.makeAIMissionAddViewController()
//                self.present(aiVC, animated: true)
            }
        }
        
        menuView.show(in: self.view)
    }
}

#Preview {
    AppDIContainer.shared.makeScheduleViewController()
}
