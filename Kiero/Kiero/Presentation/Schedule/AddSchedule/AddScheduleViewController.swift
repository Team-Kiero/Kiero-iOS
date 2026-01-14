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
    
    // 요일
    private let daySectionTitle = UILabel().then {
        $0.text = "요일"
        $0.font = .title3_16_SB
        $0.textColor = .white
    }
    
    private let repeatLabel = UILabel().then {
        $0.text = "매주 반복"
        $0.font = .body4_12_R
        $0.textColor = .white
    }
    
    private let repeatSwitch = UISwitch().then {
        $0.onTintColor = .main
        $0.backgroundColor = .gray800
        $0.layer.cornerRadius = 16
        $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    private let weekdaySelectionView = WeekdaySelectionView()
    
    // 시간
    private let timeSectionTitle = UILabel().then {
        $0.text = "시간"
        $0.font = .title3_16_SB
        $0.textColor = .white
    }
    
    private let timeSelectionView = TimeSelectionView()
    
    // 컬러
    private let colorSectionTitle = UILabel().then {
        $0.text = "컬러"
        $0.font = .title3_16_SB
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
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        view.addSubviews(navigationBar, pagingHeader,
                         titleTextField,
                         daySectionTitle, repeatLabel, repeatSwitch,
                         weekdaySelectionView,
                         timeSectionTitle, timeSelectionView,
                         colorSectionTitle, selectedColorChip, colorArrowButton)
        
        pagingHeader.configure(title: "12.8(월) - 12.14(일)", isLeftEnabled: true, isRightEnabled: true)
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
            $0.top.equalTo(pagingHeader.snp.bottom).offset(32)
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
            $0.trailing.equalTo(repeatSwitch.snp.leading).offset(-8)
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
        navigationBar.leftButtonAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        navigationBar.rightButtonAction = { [weak self] in
            guard let self = self else { return }
            
            guard let title = self.titleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                Toast.show(message: "일정 이름을 입력해주세요.")
                return
            }
            
            if self.weekdaySelectionView.selectedIndices.isEmpty {
                Toast.show(message: "요일을 선택해주세요.")
                return
            }
            
            if let start = self.currentStartTime, let end = self.currentEndTime {
                if start >= end {
                    Toast.show(message: "종료시간은 시작시간보다 늦어야 합니다.")
                    return
                }
            }
            
            self.view.endEditing(true)
            self.dismiss(animated: true)
        }
        
        timeSelectionView.startTimeTapAction = { [weak self] in
            self?.presentTimePicker(isStart: true)
        }
        
        timeSelectionView.endTimeTapAction = { [weak self] in
            self?.presentTimePicker(isStart: false)
        }
        
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        colorArrowButton.addTarget(self, action: #selector(didTapColorPicker), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func presentTimePicker(isStart: Bool) {
        timeSelectionView.updateFieldSelection(isStart: isStart, isSelected: true)
        
        let vc = TimePickerViewController()
        vc.configure(isStart: isStart)
        vc.modalPresentationStyle = .overFullScreen
        
        let savedDate = isStart ? currentStartTime : currentEndTime
        vc.setInitialTime(savedDate)
        
        vc.onTimeSelected = { [weak self] selectedTime in
            self?.timeSelectionView.updateTime(isStart: isStart, time: selectedTime)
            if isStart { self?.currentStartTime = vc.selectedDatePickerDate }
            else { self?.currentEndTime = vc.selectedDatePickerDate }
        }
        
        vc.onDismiss = { [weak self] in
            self?.timeSelectionView.updateFieldSelection(isStart: true, isSelected: false)
            self?.timeSelectionView.updateFieldSelection(isStart: false, isSelected: false)
        }
        
        self.present(vc, animated: false)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
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
