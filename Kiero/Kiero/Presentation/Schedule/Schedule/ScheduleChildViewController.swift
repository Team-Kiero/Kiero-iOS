//
//  ScheduleChildViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit
import Combine

import SnapKit
import Then

final class ScheduleChildViewController: BaseViewController<ScheduleViewModel> {
    
    // MARK: - Properties
    
    override var viewModel: ScheduleViewModel? {
        didSet {
            guard let vm = viewModel else { return }
            self.bind(viewModel: vm)
        }
    }
    
    let scheduleView = ScheduleView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = scheduleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: ScheduleViewModel) {
        cancellables.removeAll()
        
        let prevWeek = PassthroughSubject<Void, Never>()
        let nextWeek = PassthroughSubject<Void, Never>()
        
        scheduleView.pagingHeader.onLeftButtonTapped = { prevWeek.send(()) }
        scheduleView.pagingHeader.onRightButtonTapped = { nextWeek.send(()) }
        
        let input = ScheduleViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            prevWeekTapped: prevWeek.eraseToAnyPublisher(),
            nextWeekTapped: nextWeek.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.headerInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] info in
                self?.scheduleView.pagingHeader.configure(
                    title: info.title,
                    isLeftEnabled: info.leftEnabled,
                    isRightEnabled: info.rightEnabled
                )
            }.store(in: &cancellables)
        
        output.filteredSchedules
            .receive(on: RunLoop.main)
            .sink { [weak self] schedules in
                self?.scheduleView.updateSchedules(schedules)
            }.store(in: &cancellables)
        
        output.weeklyDates
            .receive(on: RunLoop.main)
            .sink { [weak self] dates in
                self?.scheduleView.timeTableView.updateDaysDates(dates)
            }.store(in: &cancellables)
    }
}
