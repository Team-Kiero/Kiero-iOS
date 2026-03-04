//
//  TimeTableViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit
import Combine

import SnapKit
import Then

final class TimeTableViewController: BaseViewController<ScheduleViewModel> {
    
    // MARK: - Properties
    
    override var viewModel: ScheduleViewModel? {
        didSet {
            guard let vm = viewModel else { return }
            self.bind(viewModel: vm)
        }
    }
    
    let prevButtonTapped = PassthroughSubject<Void, Never>()
    let nextButtonTapped = PassthroughSubject<Void, Never>()
    
    let scheduleView = ScheduleView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = scheduleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(viewModel: ScheduleViewModel, diContainer: any ViewControllerFactory) {
        super.init(viewModel: viewModel, diContainer: diContainer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: ScheduleViewModel) {
        cancellables.removeAll()
        
        let prevWeek = PassthroughSubject<Void, Never>()
        let nextWeek = PassthroughSubject<Void, Never>()
        
        scheduleView.pagingHeader.onLeftButtonTapped = { prevWeek.send(()) }
        scheduleView.pagingHeader.onRightButtonTapped = { nextWeek.send(()) }
        scheduleView.timeTableView.onScheduleTap = { [weak self] schedule in
            self?.presentScheduleDetail(schedule)
        }
        
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
    
    private func setAction() {
        scheduleView.pagingHeader.onLeftButtonTapped = { [weak self] in
            self?.prevButtonTapped.send(())
        }
        scheduleView.pagingHeader.onRightButtonTapped = { [weak self] in
            self?.nextButtonTapped.send(())
        }
    }
    
    func updateHeader(title: String, leftEnabled: Bool, rightEnabled: Bool) {
        scheduleView.pagingHeader.configure(
            title: title,
            isLeftEnabled: leftEnabled,
            isRightEnabled: rightEnabled
        )
    }
    
    func updateSchedules(_ schedules: [Schedule]) {
        scheduleView.updateSchedules(schedules)
    }
    
    func updateWeeklyDates(_ dates: [Date]) {
        scheduleView.timeTableView.updateDaysDates(dates)
    }
    
    private func presentScheduleDetail(_ schedule: Schedule) {
        let timeRange = "\(schedule.startTime.toShortTime) - \(schedule.endTime.toShortTime)"
        
        let detailData = DetailModel(
            title: schedule.name,
            type: .schedule(
                isRecurring: schedule.isRecurring,
                date: schedule.date,
                days: schedule.dayOfWeek,
                time: timeRange
            )
        )
        
        let bottomSheet = DetailBottomSheet(data: detailData)
        
        bottomSheet.onEditTap = { [weak self] in
            print("수정하기 클릭됨: \(schedule.name)")
            // self?.presentEditSchedule(schedule)
        }
        
        bottomSheet.onDeleteTap = { [weak self] in
            guard let self else { return }
            bottomSheet.dismiss(animated: false) {
                let dialog = DialogBox()
                dialog.configure(state: .deleteSchedule(title: schedule.name, isRecurring: schedule.isRecurring))
                
                dialog.onTapCancel = { [weak self] in
                    self?.dismiss(animated: false)
                }
                
                dialog.onTapClose = { [weak self] in
                    self?.dismiss(animated: false)
                }
                
                dialog.onTapConfirm = { [weak self] in
                    guard let self else { return }
                    self.dismiss(animated: false)
                    
                    guard let selectedDate = schedule.date else { return }
                    let isIncludeFollowing: Bool = schedule.isRecurring ? dialog.isFollowingSelected : false
                    
                    self.viewModel?.deleteSchedule(
                        scheduleId: schedule.id,
                        selectedDate: selectedDate,
                        isIncludeFollowing: isIncludeFollowing
                    )
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
}

extension TimeTableViewController: ScrollToTopAvailable {
    func scrollToTop() {
        DispatchQueue.main.async { [weak self] in
            self?.scheduleView.timeTableView.scrollToTop()
        }
    }
}
