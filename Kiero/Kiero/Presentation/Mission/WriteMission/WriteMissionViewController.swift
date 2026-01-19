//
//  WriteMissionViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class WriteMissionViewController: BaseViewController<WriteMissionViewModel> {
    
    // MARK: - Properties
    
    private var currentSelectedDate: Date = Date()
    var onMissionAdded: ((Mission) -> Void)?
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .closeDone(title: "미션 추가"))
    
    private let titleTextField = UITextField().then {
        $0.font = .body1_18_R
        $0.textColor = .white
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "미션 이름을 입력해주세요.",
            attributes: [
                .foregroundColor: UIColor.gray600
            ]
        )
    }
    
    private let deadlineView = DeadlineSettingView()
    private let rewardView = RewardSettingView(type: .write)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDeadlineDate(with: currentSelectedDate)
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        view.addSubviews(navigationBar, titleTextField,
                         deadlineView, rewardView)
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints{
            $0.top.equalToSuperview().offset(57)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview().inset(19)
        }
        
        deadlineView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(47)
        }
        
        rewardView.snp.makeConstraints {
            $0.top.equalTo(deadlineView.snp.bottom).offset(26)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    override func setDelegate() {
        titleTextField.delegate = self
    }
    
    override func addTarget() {
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        navigationBar.leftButtonAction = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        navigationBar.rightButtonAction = { [weak self] in
            guard let self = self else { return }
            
            guard let title = self.titleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                Toast.show(message: "미션 이름을 입력해주세요.")
                return
            }
            
            let rewardValue = self.rewardView.selectedReward
            
            let newMission = Mission(
                name: title,
                reward: rewardValue,
                dueAt: self.currentSelectedDate.toString(format: "yyyy-MM-dd")
            )
            
            self.onMissionAdded?(newMission)
            self.view.endEditing(true)
            self.dismiss(animated: true)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDeadlineView))
        deadlineView.addGestureRecognizer(tapGesture)
        deadlineView.isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 15 {
            let index = text.index(text.startIndex, offsetBy: 15)
            let newString = String(text[..<index])
            textField.text = newString
            Toast.show(message: "미션이 최대 글자수 15자를 초과하였습니다.")
        }
    }
    
    @objc
    private func didTapDeadlineView() {
        let endDateVC = EndDateViewController()
        
        endDateVC.setInitialDate(currentSelectedDate)
        
        endDateVC.onDateSelected = { [weak self] selectedDate in
            guard let self = self else { return }
            self.currentSelectedDate = selectedDate
            self.updateDeadlineDate(with: selectedDate)
        }
        
        endDateVC.modalPresentationStyle = .overFullScreen
        self.present(endDateVC, animated: false)
    }
    
    private func updateDeadlineDate(with date: Date) {
        deadlineView.dateLabel.text = date.toFullDateString
    }
}

extension WriteMissionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.count + string.count - range.length
        
        if newLength > 15 {
            Toast.show(message: "미션이 최대 글자수 15자를 초과하였습니다.")
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    AppDIContainer.shared.makeWriteMissionViewController()
}
