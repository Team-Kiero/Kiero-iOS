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
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .closeDone(title: "일정 추가"))
    
    private let pagingHeader = PagingHeader()
    
    private let titleTextField = UITextField().then {
        $0.font = .body1_18_R
        $0.textColor = .white
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
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
    }
    
    private let colorArrowButton = UIButton().then {
        $0.setImage(UIImage(resource: .icRight), for: .normal)
        $0.tintColor = .white
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialTime()
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
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let weekDates = self.baseDate.daysOfWeek
            let isRecurring = self.repeatSwitch.isOn
            
            let start = self.currentStartTime ?? Date()
            let end = self.currentEndTime ?? Date()
            let startMin = calendar.component(.hour, from: start) * 60 + calendar.component(.minute, from: start)
            let endMin = calendar.component(.hour, from: end) * 60 + calendar.component(.minute, from: end)
            
            if startMin >= endMin {
                Toast.show(message: "종료시간은 시작시간보다 늦어야 합니다.")
                return
            }
            
            let existingSchedules = self.viewModel?.scheduleList ?? []
            
            let isOverlapping = existingSchedules.contains { existing in
                let existingDayIndices = existing.dayIndices
                let hasCommonDay = !Set(selectedIndices).isDisjoint(with: Set(existingDayIndices))
                
                if hasCommonDay {
                    let exStart = self.convertTimeToMinutes(existing.startTime)
                    let exEnd = self.convertTimeToMinutes(existing.endTime)
                    let isTimeOverlapping = startMin < exEnd && exStart < endMin
                    
                    if isTimeOverlapping {
                        if isRecurring || existing.isRecurring {
                            return true
                        }
                        
                        if let existingDateStr = existing.date,
                           let existingDate = existingDateStr.toDate(format: "yyyy-MM-dd") {
                            
                            return selectedIndices.contains { index in
                                let targetDate = calendar.startOfDay(for: weekDates[index])
                                return calendar.isDate(targetDate, inSameDayAs: existingDate)
                            }
                        }
                        return true
                    }
                }
                return false
            }
            
            if isOverlapping {
                Toast.show(message: "해당 시간에 이미 등록된 일정이 있습니다.")
                return
            }
            
            if isRecurring {
                let hasPastDay = selectedIndices.contains { calendar.startOfDay(for: weekDates[$0]) < today }
                if hasPastDay {
                    Toast.show(message: "과거 요일을 포함하여 반복 일정을 시작할 수 없습니다.")
                    return
                }
            } else {
                let hasPastDate = selectedIndices.contains { calendar.startOfDay(for: weekDates[$0]) < today }
                if hasPastDate {
                    Toast.show(message: "지난 날짜에는 일정을 추가할 수 없습니다.")
                    return
                }
            }
            
            let colorMapping: [UIColor: String] = [
                .schedule1: "SCHEDULE1", .schedule2: "SCHEDULE2",
                .schedule3: "SCHEDULE3", .schedule4: "SCHEDULE4", .schedule5: "SCHEDULE5"
            ]
            let colorCode = colorMapping[self.currentSelectedColor ?? .schedule1] ?? "SCHEDULE1"
            let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            let selectedDayStrings = selectedIndices.map { dayLabels[$0] }.joined(separator: ", ")
            let startDate = weekDates.first?.toString(format: "yyyy-MM-dd")
            
            if isRecurring {
                let newSchedule = Schedule(
                    name: title, isRecurring: true,
                    startTime: start.toString(format: "HH:mm:ss"),
                    endTime: end.toString(format: "HH:mm:ss"),
                    scheduleColor: colorCode, dayOfWeek: selectedDayStrings, date: startDate
                )
                self.onScheduleAdded?(newSchedule, self.baseDate)
            } else {
                selectedIndices.forEach { index in
                    let newSchedule = Schedule(
                        name: title, isRecurring: false,
                        startTime: start.toString(format: "HH:mm:ss"),
                        endTime: end.toString(format: "HH:mm:ss"),
                        scheduleColor: colorCode, dayOfWeek: nil,
                        date: weekDates[index].toString(format: "yyyy-MM-dd")
                    )
                    self.onScheduleAdded?(newSchedule, self.baseDate)
                }
            }
            
            self.view.endEditing(true)
            self.dismiss(animated: true)
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
        
        if text.count > 10 {
            let index = text.index(text.startIndex, offsetBy: 10)
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
            self?.selectedColorChip.isHidden = false
            self?.selectedColorChip.configure(with: selectedColor, isSelected: false)
            self?.currentSelectedColor = selectedColor
        }
        
        self.present(vc, animated: false)
    }
}

extension AddScheduleViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    AppDIContainer.shared.makeAddScheduleViewController()
}
