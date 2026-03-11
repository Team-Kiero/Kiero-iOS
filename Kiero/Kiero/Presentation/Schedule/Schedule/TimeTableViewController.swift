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
        
        viewModel.editErrorMessage
            .receive(on: RunLoop.main)
            .sink { message in
                Toast.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.isEditSuccess
            .receive(on: RunLoop.main)
            .sink {
                Toast.show(message: "일정이 수정되었어요.")
            }
            .store(in: &cancellables)
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
    
    private func shouldShowEditDeleteButtons(for schedule: Schedule) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let nowMin = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        let todayStr = now.toString(format: "yyyy-MM-dd")
        let isToday = schedule.date == todayStr
        
        if isToday, let startDate = schedule.startTime.toDate(format: "HH:mm:ss") {
            let startMin = calendar.component(.hour, from: startDate) * 60 + calendar.component(.minute, from: startDate)
            if startMin <= nowMin { return false }
        }
        
        if let status = schedule.scheduleStatus, status != "PENDING" {
            return false
        }
        
        if isToday, let endDate = schedule.endTime.toDate(format: "HH:mm:ss") {
            let endMin = calendar.component(.hour, from: endDate) * 60 + calendar.component(.minute, from: endDate)
            let allSchedules = viewModel?.scheduleList.value ?? []
            
            let hasActedLaterSchedule = allSchedules.contains { other in
                guard other.id != schedule.id,
                      other.date == schedule.date,
                      let otherStart = other.startTime.toDate(format: "HH:mm:ss") else { return false }
                let otherStartMin = calendar.component(.hour, from: otherStart) * 60 + calendar.component(.minute, from: otherStart)
                let isAfter = otherStartMin >= endMin
                let isActed = other.scheduleStatus != nil && other.scheduleStatus != "PENDING"
                return isAfter && isActed
            }
            if hasActedLaterSchedule { return false }
        }
        
        return true
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
        
        let canEdit = shouldShowEditDeleteButtons(for: schedule)
        let bottomSheet = DetailBottomSheet(data: detailData, showEditDelete: canEdit)
        
        bottomSheet.onEditTap = { [weak self] in
            guard let self = self else { return }
            bottomSheet.dismiss(animated: false) {
                let editVC = AppDIContainer.shared.makeEditScheduleViewController(schedule: schedule)
                editVC.modalPresentationStyle = .overFullScreen
                
                editVC.onEditConfirmed = { [weak self] request, _, completion in
                    guard let self = self,
                          let selectedDate = schedule.date else { return }
                    self.viewModel?.editSchedule(
                        scheduleId: schedule.id,
                        selectedDate: selectedDate,
                        request: request,
                        completion: completion
                    )
                }
                
                self.present(editVC, animated: true)
            }
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
