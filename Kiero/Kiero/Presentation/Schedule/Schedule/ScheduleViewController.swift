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

final class ScheduleViewController: BaseViewController<ScheduleViewModel> {
    
    // MARK: - Properties
    
    var onAddScheduleTap: ((Bool, [Schedule], Date) -> Void)?
    var onLogout: (() -> Void)?
    
    let scheduleChildVC: TimeTableViewController
    
    // MARK: - UI Components
    
    private let floatingButton = FloatingButton(type: .schedule)
    
    // MARK: - Init
    
    init(
        viewModel: ScheduleViewModel,
        scheduleChildVC: TimeTableViewController
    ) {
        self.scheduleChildVC = scheduleChildVC
        super.init(viewModel: viewModel)
    }
    
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
        view.addSubviews(scheduleChildVC.view, floatingButton)
        scheduleChildVC.didMove(toParent: self)
    }
    
    override func setLayout() {
        scheduleChildVC.view.snp.makeConstraints {
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
            self?.requestAddSchedule()
        }
    }
    
    private func requestAddSchedule() {
        guard let viewModel else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let currentWeekStart = now.daysOfWeek.first,
              let referenceWeekStart = viewModel.currentReferenceDate.value.daysOfWeek.first else {
            return
        }
        
        let startOfCurrentWeek = calendar.startOfDay(for: currentWeekStart)
        let startOfReferenceWeek = calendar.startOfDay(for: referenceWeekStart)
        
        let targetDate: Date = (startOfReferenceWeek < startOfCurrentWeek)
        ? now
        : viewModel.currentReferenceDate.value
        
        onAddScheduleTap?(
            viewModel.isFireLit,
            viewModel.scheduleList.value,
            targetDate
        )
    }
    
    override func bindViewModel() {
        guard let viewModel else { return }
        
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
            }
            .store(in: &cancellables)
            
        output.filteredSchedules
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schedules in
                self?.scheduleChildVC.updateSchedules(schedules)
            }
            .store(in: &cancellables)

        output.weeklyDates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dates in
                self?.scheduleChildVC.updateWeeklyDates(dates)
            }
            .store(in: &cancellables)
        
        viewModel.logoutSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.onLogout?()
            }
            .store(in: &cancellables)
    }
    
    func updateReferenceDate(_ date: Date) {
        viewModel?.currentReferenceDate.send(date)
    }
}
