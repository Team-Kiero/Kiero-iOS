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
    
    // MARK: - UI Components
    
    private lazy var navigationBar = NavigationBar(type: .main(title: "일정")).then {
        $0.rightButtonAction = { [weak self] in
            self?.presentNotificationFeed()
        }
    }
    
    private lazy var scheduleChildVC: TimeTableViewController = {
        guard let viewModel = self.viewModel else { fatalError("ViewModel is missing") }
        let vc = AppDIContainer.shared.makeTimeTableViewController(viewModel: viewModel)
        return vc
    }()
    
    private let floatingButton = FloatingButton(type: .schedule)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.refreshSchedules()
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addChild(scheduleChildVC)
        view.addSubviews(navigationBar, scheduleChildVC.view, floatingButton)
        scheduleChildVC.didMove(toParent: self)
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(57)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        scheduleChildVC.view.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(115)
        }
    }
    
    private func setAction() {
        floatingButton.tapAction = { [weak self] in
            self?.presentAddSchedule()
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
        addScheduleVC.viewModel?.isFireLit = viewModel.isFireLit
        addScheduleVC.baseDate = targetDate
        
        addScheduleVC.onScheduleAdded = { [weak self] (newSchedule: Schedule, targetDate: Date) in
            guard let self = self else { return }            
            self.viewModel?.currentReferenceDate.send(targetDate)
        }
        
        let nav = UINavigationController(rootViewController: addScheduleVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    override func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        let input = ScheduleViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            prevWeekTapped: scheduleChildVC.prevButtonTapped.eraseToAnyPublisher(),
            nextWeekTapped: scheduleChildVC.nextButtonTapped.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.headerInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.scheduleChildVC.updateHeader(
                    title: info.title,
                    leftEnabled: info.leftEnabled,
                    rightEnabled: info.rightEnabled
                )
            }.store(in: &cancellables)
            
        output.filteredSchedules
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schedules in
                self?.scheduleChildVC.updateSchedules(schedules)
            }.store(in: &cancellables)

        output.weeklyDates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dates in
                self?.scheduleChildVC.updateWeeklyDates(dates)
            }.store(in: &cancellables)
        
        viewModel.logoutSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigateToPickRole()
            }.store(in: &cancellables)
    }
    
    private func presentNotificationFeed() {
        let notificationVC = diContainer.makeNotificationFeedViewController()
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
}
