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
    
    private lazy var scheduleChildVC: ScheduleChildViewController = {
        let vc = AppDIContainer.shared.makeScheduleChildViewController()
        vc.viewModel = self.viewModel
        return vc
    }()
    
    private let missionVC = AppDIContainer.shared.makeMissionViewController()
    
    // MARK: - UI Components
    
    private let profileBox = ProfileBox(
        name: "신키로",
        profileURL: "",
        backgroundColor: .clear
    ).then {
        $0.onTap = {
            // TODO: 로그아웃VC 연결
        }
    }
    
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
        
        view.addSubviews(profileBox, segmentedControl, floatingButton)
        
        scheduleChildVC.didMove(toParent: self)
        missionVC.didMove(toParent: self)
    }
    
    override func setLayout() {
        profileBox.snp.makeConstraints {
            $0.top.equalToSuperview().offset(59)
            $0.trailing.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(profileBox.snp.bottom)
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
    
    private func isPastWeek() -> Bool {
        guard let viewModel = self.viewModel else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let currentWeekStart = now.daysOfWeek.first else { return false }
        let startOfCurrentWeek = calendar.startOfDay(for: currentWeekStart)
        
        guard let referenceWeekStart = viewModel.currentReferenceDate.value.daysOfWeek.first else { return false }
        let startOfReferenceWeek = calendar.startOfDay(for: referenceWeekStart)
        
        return startOfReferenceWeek < startOfCurrentWeek
    }
    
    private func updateFloatingButtonType() {
        let newType: FloatingButtonType = (currentTabIndex == 0) ? .schedule : .mission
        floatingButton.updateType(newType)
    }
    
    private func presentAddSchedule() {
        guard let viewModel = self.viewModel else { return }
        guard let addScheduleVC = AppDIContainer.shared.makeAddScheduleViewController() as? AddScheduleViewController else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        let currentWeekStart = now.daysOfWeek.first!
        let startOfCurrentWeek = calendar.startOfDay(for: currentWeekStart)
        
        let referenceWeekStart = viewModel.currentReferenceDate.value.daysOfWeek.first!
        let startOfReferenceWeek = calendar.startOfDay(for: referenceWeekStart)
        
        let targetDate: Date = (startOfReferenceWeek < startOfCurrentWeek) ? now : viewModel.currentReferenceDate.value
        
        addScheduleVC.viewModel?.scheduleList = viewModel.scheduleList.value
        addScheduleVC.baseDate = targetDate
        
        addScheduleVC.onScheduleAdded = { [weak self] (newSchedule: Schedule, finalDate: Date) in
            guard let self = self else { return }
           
            self.viewModel?.addSchedule(newSchedule)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewModel?.currentReferenceDate.send(finalDate)
            }
        }
        
        let nav = UINavigationController(rootViewController: addScheduleVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    private func presentAddMission() {
        let menuView = MissionFloatingMenuView()
        
        menuView.onMenuSelected = { [weak self] index in
            guard let self = self else { return }
            
            if index == 0 {
                guard let writeVC = self.diContainer.makeWriteMissionViewController() as? WriteMissionViewController else { return }
                
                writeVC.onMissionAdded = { [weak self] (newMission: Mission) in
                    if let missionViewController = self?.missionVC as? MissionViewController {
                        missionViewController.viewModel?.addMission(newMission)
                    }
                }
                
                let nav = UINavigationController(rootViewController: writeVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                
            } else {
                guard let aiVC = self.diContainer.makeAIMissionViewController() as? AIMissionViewController else { return }
                
                aiVC.onMissionAdded = { [weak self] (newMission: Mission) in
                    if let missionVC = self?.missionVC as? MissionViewController {
                        missionVC.viewModel?.addMission(newMission)
                    }
                }
                
                let nav = UINavigationController(rootViewController: aiVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
        
        menuView.show(in: self.view)
    }
}

#Preview {
    AppDIContainer.shared.makeScheduleViewController()
}
