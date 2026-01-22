//
//  TimePickerViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/14/26.
//

import UIKit

import SnapKit
import Then

final class TimePickerViewController: BaseBottomSheetViewController {
    
    // MARK: - Properties
    
    private var isStartField: Bool = true
    var onDismiss: (() -> Void)?
    var onTimeSelected: ((Date) -> Void)?
    var selectedDatePickerDate: Date {
        return datePicker.date
    }
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .closeDone(title: "시각"), backgroundColor: .gray900)
    
    private let datePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .wheels
        $0.datePickerMode = .time
        $0.setValue(UIColor.white, forKey: "textColor")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setAction()
    }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        containerView.addSubviews(navigationBar, datePicker)
    }
    
    private func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(32)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(25)
            $0.horizontalEdges.equalToSuperview().inset(9)
            $0.bottom.equalToSuperview().inset(32)
        }
    }
    
    private func setAction() {
        navigationBar.leftButtonAction = { [weak self] in
            self?.onDismiss?()
            self?.dismissSheetWithoutSaving()
        }
        
        navigationBar.rightButtonAction = { [weak self] in
            guard let self = self else { return }
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: self.datePicker.date)
            var finalDate = self.datePicker.date
            
            if hour < 8 {
                if let minDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: finalDate) {
                    finalDate = minDate
                }
                Toast.show(message: "시각은 08:00AM부터 설정가능합니다.")
            } else if hour >= 22 {
                if let maxDate = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: finalDate) {
                    finalDate = maxDate
                }
                Toast.show(message: "시각은 10:00PM까지 설정가능합니다.")
            }
            
            self.onTimeSelected?(finalDate)
            self.hideSheet()
        }
    }
    
    override func hideSheet() {
        self.onDismiss?()
        super.hideSheet()
    }
    
    private func dismissSheetWithoutSaving() {
        super.hideSheet()
    }
    
    func configure(isStart: Bool) {
        self.isStartField = isStart
        let title = isStart ? "시작" : "종료"
        navigationBar.updateTitle(title)
    }
    
    func setInitialTime(_ date: Date?) {
        if let date = date {
            datePicker.date = date
        } else {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 12
            components.minute = 0
            if let defaultDate = calendar.date(from: components) {
                datePicker.date = defaultDate
            }
        }
    }
}
