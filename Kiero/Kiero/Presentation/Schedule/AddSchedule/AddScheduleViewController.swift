//
//  AddScheduleViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/13/26.
//

import UIKit

import SnapKit
import Then

class AddScheduleViewController: BaseViewController<AddScheduleViewModel> {
    
    // MARK: - Properties
    
    private var currentStartTime: Date?
    private var currentEndTime: Date?
    private var currentSelectedColor: UIColor?
    var onScheduleAdded: ((Schedule, Date) -> Void)?
    var baseDate: Date = Date() {
        didSet {
            updatePagingTitle()
        }
    }
    
    var isEditMode: Bool = false
    var editingSchedule: Schedule?
    var onEditConfirmed: ((EditScheduleRequestDTO, Bool, @escaping (Bool) -> Void) -> Void)?
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .closeDone(title: "일정 추가"))
    
    private let pagingHeader = PagingHeader()
    
    private let titleTextField = UITextField().then {
        $0.font = .body1_18_R
        $0.textColor = .gray100
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "일정 이름을 입력해주세요.",
            attributes: [
                .foregroundColor: UIColor.gray600
            ]
        )
    }
    
    private let daySectionTitle = UILabel().then {
        $0.setTypo(.title3_16_SB, text: "요일")
        $0.textColor = .white
    }
    
    private let repeatLabel = UILabel().then {
        $0.setTypo(.body4_12_R, text: "매주 반복")
        $0.textColor = .white
    }
    
    private let repeatSwitch = UISwitch().then {
        $0.onTintColor = .main
        $0.backgroundColor = .gray800
        $0.layer.cornerRadius = 16
        $0.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }
    
    private let weekdaySelectionView = WeekdaySelectionView()
    
    private let timeSectionTitle = UILabel().then {
        $0.setTypo(.title3_16_SB, text: "시간")
        $0.textColor = .white
    }
    
    private let timeSelectionView = TimeSelectionView()
    
    private let colorSectionTitle = UILabel().then {
        $0.setTypo(.title3_16_SB, text: "컬러")
        $0.textColor = .white
    }
    
    private let selectedColorChip = ColorChip().then {
        $0.isUserInteractionEnabled = false
    }
    
    private let colorArrowButton = UIButton().then {
        $0.setImage(UIImage(resource: .icRight), for: .normal)
        $0.tintColor = .white
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEditMode {
            setupEditMode()
        } else {
            setInitialTime()
            viewModel?.fetchDefaultColor()
        }
        
        addTarget()
        updatePagingTitle()
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        view.addSubviews(navigationBar, pagingHeader,
                         titleTextField,
                         daySectionTitle, repeatLabel, repeatSwitch,
                         weekdaySelectionView,
                         timeSectionTitle, timeSelectionView,
                         colorSectionTitle, selectedColorChip, colorArrowButton)
        
        let weekDates = Date().daysOfWeek
        
        if let firstDay = weekDates.first, let lastDay = weekDates.last {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "M.d(E)"
            formatter.locale = Locale(identifier: "ko_KR")
            
            let startStr = formatter.string(from: firstDay)
            let endStr = formatter.string(from: lastDay)
            
            pagingHeader.configure(
                title: "\(startStr) - \(endStr)",
                isLeftEnabled: true,
                isRightEnabled: true
            )
        }
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints{
            $0.top.equalToSuperview().offset(57)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        pagingHeader.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(28)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(pagingHeader.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(19)
        }
        
        daySectionTitle.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(28)
            $0.leading.equalToSuperview().inset(15)
        }
        
        repeatSwitch.snp.makeConstraints {
            $0.centerY.equalTo(daySectionTitle)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        repeatLabel.snp.makeConstraints {
            $0.centerY.equalTo(daySectionTitle)
            $0.trailing.equalTo(repeatSwitch.snp.leading)
        }
        
        weekdaySelectionView.snp.makeConstraints {
            $0.top.equalTo(daySectionTitle.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(19)
        }
        
        timeSectionTitle.snp.makeConstraints {
            $0.top.equalTo(daySectionTitle.snp.bottom).offset(127)
            $0.leading.equalToSuperview().inset(15)
        }
        
        timeSelectionView.snp.makeConstraints {
            $0.top.equalTo(timeSectionTitle.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(15)
        }
        
        colorSectionTitle.snp.makeConstraints {
            $0.top.equalTo(timeSectionTitle.snp.bottom).offset(132)
            $0.leading.equalToSuperview().inset(15)
        }
        
        selectedColorChip.snp.makeConstraints {
            $0.centerY.equalTo(colorSectionTitle)
            $0.trailing.equalTo(colorArrowButton.snp.leading).offset(-10)
        }
        
        colorArrowButton.snp.makeConstraints {
            $0.centerY.equalTo(colorSectionTitle)
            $0.trailing.equalToSuperview().inset(10)
        }
    }
    
    func configure(with schedule: Schedule) {
        isEditMode = true
        editingSchedule = schedule
    }
    
    override func addTarget() {
        pagingHeader.onLeftButtonTapped = { [weak self] in
            self?.moveWeek(value: -1)
        }
        
        pagingHeader.onRightButtonTapped = { [weak self] in
            self?.moveWeek(value: 1)
        }
        
        navigationBar.leftButtonAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        navigationBar.rightButtonAction = { [weak self] in
            guard let self = self else { return }
            
            guard let title = self.titleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                Toast.show(message: "일정 이름을 입력해주세요.")
                return
            }
            
            let selectedIndices = self.weekdaySelectionView.selectedIndices.sorted()
            if selectedIndices.isEmpty {
                Toast.show(message: "요일을 선택해주세요.")
                return
            }
            
            let start = self.currentStartTime ?? Date()
            let end = self.currentEndTime ?? Date()
            let startMin = Calendar.current.component(.hour, from: start) * 60 + Calendar.current.component(.minute, from: start)
            let endMin = Calendar.current.component(.hour, from: end) * 60 + Calendar.current.component(.minute, from: end)
            
            if startMin >= endMin {
                Toast.show(message: "종료시간은 시작시간보다 늦어야 합니다.")
                return
            }
            
            if self.isEditMode {
                self.handleEditConfirm()
                return
            }
            
            let calendar = Calendar.current
            let now = Date()
            let today = calendar.startOfDay(for: now)
            let weekDates = self.baseDate.daysOfWeek
            let isRecurring = self.repeatSwitch.isOn
            let isFireLit = self.viewModel?.isFireLit ?? false
            
            let currentTimeMin = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
            let currentWeekDayIndex = (calendar.component(.weekday, from: now) + 5) % 7
            let isCurrentWeek = calendar.isDate(self.baseDate, inSameDayAs: today) || (weekDates.first! <= today && weekDates.last! >= today)
            
            if isRecurring {
                let hasPastDayInWeek = selectedIndices.contains { $0 < currentWeekDayIndex }
                let isTodaySelected = selectedIndices.contains(currentWeekDayIndex)
                let isTodayTimePast = isTodaySelected && (startMin < currentTimeMin)
                
                if isCurrentWeek && (hasPastDayInWeek || isTodayTimePast) {
                    Toast.show(message: "일정이 등록되었어요. (오늘 일정은 마감되어 다음 주부터 적용돼요!)")
                } else {
                    Toast.show(message: "일정이 등록되었어요.")
                }
            } else {
                let hasToday = selectedIndices.contains { index in
                    calendar.isDate(weekDates[index], inSameDayAs: today)
                }
                
                if hasToday {
                    if startMin < currentTimeMin {
                        Toast.show(message: "이미 지난 시간에는 일정을 등록할 수 없어요.")
                        return
                    }
                    
                    if isFireLit {
                        Toast.show(message: "오늘 일정이 마감되어, 일정을 추가할 수 없어요.")
                        return
                    }
                    
                    let endMin = calendar.component(.hour, from: end) * 60 + calendar.component(.minute, from: end)
                    let scheduleList = viewModel?.scheduleList ?? []
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let hasActedLaterSchedule = scheduleList.contains { other in
                        guard let otherStart = other.startTime.toDate(format: "HH:mm:ss"),
                              let otherDateStr = other.date,
                              let otherDate = dateFormatter.date(from: otherDateStr) else { return false }
                        guard calendar.isDate(otherDate, inSameDayAs: now) else { return false }
                        let otherStartMin = calendar.component(.hour, from: otherStart) * 60 + calendar.component(.minute, from: otherStart)
                        let isAfter = otherStartMin >= endMin
                        let isActed = other.scheduleStatus != nil && other.scheduleStatus != "PENDING"
                        return isAfter && isActed
                    }
                    
                    if hasActedLaterSchedule {
                        Toast.show(message: "이후의 일정이 이미 시작되어, 일정을 추가할 수 없어요.")
                        return
                    }
                }
                
                let hasPastDate = selectedIndices.contains { index in
                    calendar.startOfDay(for: weekDates[index]) < today
                }
                
                if hasPastDate {
                    Toast.show(message: "과거 날짜에는 일정을 추가할 수 없습니다.")
                    return
                }
                
                Toast.show(message: "일정이 등록되었어요.")
            }
            
            self.navigationBar.isRightButtonEnabled = false
            
            let colorMapping: [UIColor: String] = [
                .schedule1: "SCHEDULE1", .schedule2: "SCHEDULE2",
                .schedule3: "SCHEDULE3", .schedule4: "SCHEDULE4", .schedule5: "SCHEDULE5"
            ]
            let colorCode = colorMapping[self.currentSelectedColor ?? .schedule1] ?? "SCHEDULE1"
            
            let startTimeStr = start.toString(format: "HH:mm:ss")
            let endTimeStr = end.toString(format: "HH:mm:ss")
            
            if isRecurring {
                let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
                let dayOfWeekStr = selectedIndices.map { dayLabels[$0] }.joined(separator: ", ")
                let firstOrderDate = weekDates[selectedIndices[0]].toString(format: "yyyy-MM-dd")
                
                let requestDTO = AddScheduleRequestDTO(
                    name: title,
                    isRecurring: true,
                    firstOrderDate: firstOrderDate,
                    startTime: startTimeStr,
                    endTime: endTimeStr,
                    scheduleColor: colorCode,
                    dayOfWeek: dayOfWeekStr,
                    dates: nil
                )
                viewModel?.addSchedule(request: requestDTO)
            } else {
                let datesStr = selectedIndices.map { weekDates[$0].toString(format: "yyyy-MM-dd") }.joined(separator: ", ")
                
                let requestDTO = AddScheduleRequestDTO(
                    name: title,
                    isRecurring: false,
                    firstOrderDate: nil,
                    startTime: startTimeStr,
                    endTime: endTimeStr,
                    scheduleColor: colorCode,
                    dayOfWeek: nil,
                    dates: datesStr
                )
                viewModel?.addSchedule(request: requestDTO)
            }
            
            self.view.endEditing(true)
        }
        
        timeSelectionView.startTimeTapAction = { [weak self] in self?.presentTimePicker(isStart: true) }
        timeSelectionView.endTimeTapAction = { [weak self] in self?.presentTimePicker(isStart: false) }
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        colorArrowButton.addTarget(self, action: #selector(didTapColorPicker), for: .touchUpInside)
    }
    
    private func convertTimeToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":").map { Int($0) ?? 0 }
        if components.count >= 2 {
            return components[0] * 60 + components[1]
        }
        return 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isAddSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                
                let name = self.titleTextField.text ?? ""
                let isRecurring = self.repeatSwitch.isOn
                let startTime = self.currentStartTime?.toString(format: "HH:mm:ss") ?? ""
                let endTime = self.currentEndTime?.toString(format: "HH:mm:ss") ?? ""
                
                let colorMapping: [UIColor: String] = [
                    .schedule1: "SCHEDULE1", .schedule2: "SCHEDULE2",
                    .schedule3: "SCHEDULE3", .schedule4: "SCHEDULE4", .schedule5: "SCHEDULE5"
                ]
                let colorName = colorMapping[self.currentSelectedColor ?? .schedule1] ?? "SCHEDULE1"
                
                let hexCode = self.currentSelectedColor?.toHexString() ?? "#FF5C5C"
                
                let selectedIndices = self.weekdaySelectionView.selectedIndices.sorted()
                let weekDates = self.baseDate.daysOfWeek
                
                if let firstIndex = selectedIndices.first {
                    let targetDate = weekDates[firstIndex]
                    
                    let actualSchedule = Schedule(
                        id: Int(Date().timeIntervalSince1970 * 1000),
                        name: name,
                        isRecurring: isRecurring,
                        startTime: startTime,
                        endTime: endTime,
                        scheduleColor: colorName,
                        colorCode: hexCode,
                        dayOfWeek: isRecurring ? selectedIndices.map { ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][$0] }.joined(separator: ", ") : nil,
                        date: isRecurring ? nil : targetDate.toString(format: "yyyy-MM-dd"),
                        scheduleStatus: nil
                    )
                    
                    self.onScheduleAdded?(actualSchedule, targetDate)
                }
                
                self.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                Toast.show(message: message)
                self?.navigationBar.isRightButtonEnabled = true
            }
            .store(in: &cancellables)
        
        viewModel.defaultColor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] color in
                guard let self = self else { return }
                guard !self.isEditMode else { return }
                
                if self.currentSelectedColor == nil {
                    self.currentSelectedColor = color
                    self.selectedColorChip.isHidden = false
                    self.selectedColorChip.configure(with: color, isSelected: false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func moveWeek(value: Int) {
        let calendar = Calendar.current
        guard let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: baseDate) else { return }
        
        let now = Date()
        let currentWeekStart = now.daysOfWeek.first!
        let startOfCurrentWeek = calendar.startOfDay(for: currentWeekStart)
        let maxDate = calendar.date(byAdding: .weekOfYear, value: 12, to: now)!
        
        let newDateWeekStart = calendar.startOfDay(for: newDate.daysOfWeek.first!)
        
        if newDateWeekStart < startOfCurrentWeek {
            return
        }
        
        if newDateWeekStart <= calendar.startOfDay(for: maxDate) {
            self.baseDate = newDate
        } else {
            Toast.show(message: "현재 날짜 기준 12주 이내만 선택 가능합니다.")
        }
    }
    
    private func setInitialTime() {
        let calendar = Calendar.current
        let now = Date()
        
        var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
        startComponents.hour = 12
        startComponents.minute = 0
        let defaultStart = calendar.date(from: startComponents)
        
        var endComponents = startComponents
        endComponents.hour = 12
        let defaultEnd = calendar.date(from: endComponents)
        
        self.currentStartTime = defaultStart
        self.currentEndTime = defaultEnd
        
        if let start = defaultStart, let end = defaultEnd {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh : mm a"
            formatter.locale = Locale(identifier: "en_US")
            
            timeSelectionView.updateTime(isStart: true, time: formatter.string(from: start))
            timeSelectionView.updateTime(isStart: false, time: formatter.string(from: end))
        }
    }
    
    private func updatePagingTitle() {
        let weekDates = baseDate.daysOfWeek
        guard let firstDay = weekDates.first, let lastDay = weekDates.last else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let title = "\(formatter.string(from: firstDay)) - \(formatter.string(from: lastDay))"
        
        if isEditMode {
            pagingHeader.configure(title: title, isLeftEnabled: false, isRightEnabled: false)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let currentWeekStart = now.daysOfWeek.first!
        let startOfCurrentWeek = calendar.startOfDay(for: currentWeekStart)
        let maxDate = calendar.date(byAdding: .weekOfYear, value: 12, to: now)!
        let isLeftEnabled = calendar.startOfDay(for: firstDay) > startOfCurrentWeek
        let isRightEnabled = calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate)! <= calendar.startOfDay(for: maxDate)
        
        pagingHeader.configure(title: title, isLeftEnabled: isLeftEnabled, isRightEnabled: isRightEnabled)
    }
    
    private func presentTimePicker(isStart: Bool) {
        timeSelectionView.updateFieldSelection(isStart: isStart, isSelected: true)
        
        let vc = TimePickerViewController()
        vc.configure(isStart: isStart)
        vc.modalPresentationStyle = .overFullScreen
        
        let savedDate = isStart ? currentStartTime : currentEndTime
        vc.setInitialTime(savedDate)
        
        vc.onTimeSelected = { [weak self] selectedTime in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh : mm a"
            let englishTimeString = formatter.string(from: selectedTime)
            
            self.timeSelectionView.updateTime(isStart: isStart, time: englishTimeString)
            
            if isStart {
                self.currentStartTime = selectedTime
            } else {
                self.currentEndTime = selectedTime
            }
        }
        
        vc.onDismiss = { [weak self] in
            self?.timeSelectionView.updateFieldSelection(isStart: true, isSelected: false)
            self?.timeSelectionView.updateFieldSelection(isStart: false, isSelected: false)
        }
        
        self.present(vc, animated: false)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 8 {
            let index = text.index(text.startIndex, offsetBy: 8)
            let newString = String(text[..<index])
            textField.text = newString
        }
    }
    
    @objc
    private func didTapColorPicker() {
        let vc = ColorPickerViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.initialSelectedColor = currentSelectedColor
        
        vc.onColorSelected = { [weak self] selectedColor in
            guard let self = self else { return }
            self.selectedColorChip.isHidden = false
            self.selectedColorChip.configure(with: selectedColor, isSelected: false)
            self.currentSelectedColor = selectedColor
        }
        
        self.present(vc, animated: false)
    }
    
    private func setupEditMode() {
        guard let schedule = editingSchedule else { return }
        navigationBar.setTitle("일정 수정")
        titleTextField.text = schedule.name
        repeatSwitch.isOn = schedule.isRecurring
        
        if schedule.isRecurring, let dayOfWeek = schedule.dayOfWeek {
            if let dateStr = schedule.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: dateStr) {
                    baseDate = date
                }
            }
            
            let dayLabels = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
            let indices = dayOfWeek.components(separatedBy: ", ").compactMap { dayLabels[$0.trimmingCharacters(in: .whitespaces)] }
            weekdaySelectionView.setSelectedIndices(indices)
            updatePagingTitle()
        } else if let dateStr = schedule.date {
            weekdaySelectionView.isSingleSelectionMode = true
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let date = formatter.date(from: dateStr) {
                baseDate = date
                
                let weekDates = baseDate.daysOfWeek
                if let index = weekDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                    weekdaySelectionView.setSelectedIndices([index])
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        if let start = formatter.date(from: schedule.startTime) {
            currentStartTime = start
            let display = DateFormatter()
            display.dateFormat = "hh : mm a"
            display.locale = Locale(identifier: "en_US")
            timeSelectionView.updateTime(isStart: true, time: display.string(from: start))
        }
        if let end = formatter.date(from: schedule.endTime) {
            currentEndTime = end
            let display = DateFormatter()
            display.dateFormat = "hh : mm a"
            display.locale = Locale(identifier: "en_US")
            timeSelectionView.updateTime(isStart: false, time: display.string(from: end))
        }
        
        let color = UIColor(hex: schedule.colorCode)
        currentSelectedColor = color
        selectedColorChip.isHidden = false
        selectedColorChip.configure(with: color, isSelected: false)
    }
    
    private func handleEditConfirm() {
        guard let schedule = editingSchedule else { return }
        
        let colorMapping: [UIColor: String] = [
            .schedule1: "SCHEDULE1", .schedule2: "SCHEDULE2",
            .schedule3: "SCHEDULE3", .schedule4: "SCHEDULE4", .schedule5: "SCHEDULE5"
        ]
        let colorCode = colorMapping[currentSelectedColor ?? .schedule1] ?? "SCHEDULE1"
        let startTimeStr = (currentStartTime ?? Date()).toString(format: "HH:mm:ss")
        let endTimeStr = (currentEndTime ?? Date()).toString(format: "HH:mm:ss")
        let isRecurring = repeatSwitch.isOn
        let wasRecurring = schedule.isRecurring
        let weekDates = baseDate.daysOfWeek
        let selectedIndices = weekdaySelectionView.selectedIndices.sorted()
        
        let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        let dayOfWeekStr: String? = isRecurring ? selectedIndices.map { dayLabels[$0] }.joined(separator: ", ") : nil
        let datesStr: String? = isRecurring ? nil : selectedIndices.map { weekDates[$0].toString(format: "yyyy-MM-dd") }.joined(separator: ", ")
        
        let originalDayIndices: Set<Int> = {
            guard let dayOfWeek = schedule.dayOfWeek else { return [] }
            let dayLabelsKor = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
            return Set(dayOfWeek.components(separatedBy: ", ").compactMap { dayLabelsKor[$0.trimmingCharacters(in: .whitespaces)] })
        }()
        let currentDayIndices = Set(selectedIndices)
        let isDayChanged = originalDayIndices != currentDayIndices
        let isRecurringChanged = wasRecurring != isRecurring
        
        let shouldShowDialog = wasRecurring && !isDayChanged && !isRecurringChanged
        
        if shouldShowDialog {
            let dialog = DialogBox()
            dialog.configure(state: .editSchedule(title: titleTextField.text ?? schedule.name, isRecurring: wasRecurring))
            
            dialog.onTapCancel = { [weak self] in
                self?.dismiss(animated: false)
            }
            
            dialog.onTapClose = { [weak self] in
                self?.dismiss(animated: false)
            }
            
            dialog.onTapConfirm = { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: false)
                
                let isIncludeFollowing: Bool? = dialog.isFollowingSelected
                
                let finalRequest = EditScheduleRequestDTO(
                    name: self.titleTextField.text ?? "",
                    isRecurring: isRecurring,
                    startTime: startTimeStr,
                    endTime: endTimeStr,
                    scheduleColor: colorCode,
                    dayOfWeek: dayOfWeekStr,
                    dates: datesStr,
                    isIncludeFollowing: isIncludeFollowing
                )
                
                self.onEditConfirmed?(finalRequest, isIncludeFollowing ?? false) { success in
                    if success { self.dismiss(animated: true) }
                }
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
            
        } else {
            let finalRequest = EditScheduleRequestDTO(
                name: self.titleTextField.text ?? "",
                isRecurring: isRecurring,
                startTime: startTimeStr,
                endTime: endTimeStr,
                scheduleColor: colorCode,
                dayOfWeek: dayOfWeekStr,
                dates: datesStr,
                isIncludeFollowing: nil
            )
            
            self.onEditConfirmed?(finalRequest, false) { success in
                if success { self.dismiss(animated: true) }
            }
        }
    }
}

extension AddScheduleViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 8
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    AppDIContainer.shared.makeAddScheduleViewController()
}
