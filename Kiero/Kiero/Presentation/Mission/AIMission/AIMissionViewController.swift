//
//  AIMissionViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class AIMissionViewController: BaseViewController<AIMissionViewModel> {
    
    // MARK: - Properties
    
    var isAnalysisDone: Bool = false {
        didSet {
            updateViewStatus()
            if isAnalysisDone {
                missionResultView.deadlineView.dateLabel.text = currentSelectedDate.toFullDateString
            }
        }
    }
    
    var onMissionAdded: ((Mission) -> Void)?
    
    private var currentSelectedDate: Date = Date()
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .close(title: "알림장 미션 추가"))
    
    private let missionInputView = AIMissionInputView()
    
    private let missionResultView = AIMissionResultView().then {
        $0.isHidden = true
    }
    
    private let addMissionButton = CTAButton(style: .main).then {
        $0.configure(title: "분석하고 미션추가하기")
    }
    
    // MARK: - Life Cycle
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        missionResultView.deadlineView.dateLabel.text = currentSelectedDate.toFullDateString
        updateButtonState(text: "")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        view.addSubviews(navigationBar,
                         missionInputView, missionResultView,
                         addMissionButton)
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(57)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        [missionInputView, missionResultView].forEach {
            $0.snp.makeConstraints { make in
                make.top.equalTo(navigationBar.snp.bottom)
                make.horizontalEdges.equalToSuperview()
                make.bottom.equalTo(addMissionButton.snp.top).offset(-61)
            }
        }
        
        addMissionButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(74)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    override func addTarget() {
        addMissionButton.addTarget(self, action: #selector(didTapBottomButton), for: .touchUpInside)
        
        missionResultView.onDeadlineViewTapped = { [weak self] in
            self?.presentEndDateViewController()
        }
        
        navigationBar.leftButtonAction = { [weak self] in
            guard let self = self else { return }
            
            if self.isAnalysisDone {
                self.isAnalysisDone = false
            } else {
                self.dismiss(animated: true)
            }
        }
        
        missionInputView.onTextChanged = { [weak self] text in
            self?.updateButtonState(text: text)
        }
    }

    private func updateButtonState(text: String) {
        if !isAnalysisDone {
            let isValid = text.count >= 10 && text.count <= 1000
            addMissionButton.isEnabled = isValid
            addMissionButton.alpha = isValid ? 1.0 : 0.5
        } else {
            addMissionButton.isEnabled = true
            addMissionButton.alpha = 1.0
        }
    }
    
    private func updateViewStatus() {
        missionInputView.isHidden = isAnalysisDone
        missionResultView.isHidden = !isAnalysisDone
        
        let buttonTitle = isAnalysisDone ? "저장하기" : "분석하고 미션추가하기"
        addMissionButton.configure(title: buttonTitle)
        
        if !isAnalysisDone {
            updateButtonState(text: missionInputView.textView.text)
        } else {
            updateButtonState(text: "")
        }
    }
    
    @objc
    private func didTapBottomButton() {
        if !isAnalysisDone {
            // TODO: 로딩VC 진입
            self.view.endEditing(true)
            isAnalysisDone = true
        } else {
            guard let title = missionResultView.nameTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            let rewardValue = missionResultView.selectedReward
            
            let newMission = Mission(
                name: title,
                reward: rewardValue,
                dueAt: self.currentSelectedDate.toString(format: "yyyy-MM-dd")
            )
            
            self.onMissionAdded?(newMission)
            self.dismiss(animated: true)
        }
    }
    
    private func presentEndDateViewController() {
        let endDateVC = EndDateViewController()
        endDateVC.setInitialDate(currentSelectedDate)
        
        endDateVC.onDateSelected = { [weak self] selectedDate in
            guard let self = self else { return }
            self.currentSelectedDate = selectedDate
            self.missionResultView.deadlineView.dateLabel.text = selectedDate.toFullDateString
        }
        
        endDateVC.modalPresentationStyle = .overFullScreen
        self.present(endDateVC, animated: false)
    }
    
    func setAnalysisStatus(isDone: Bool) {
        self.isAnalysisDone = isDone
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        let targetInset = keyboardHeight - safeAreaBottom - 40
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: targetInset, right: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.missionInputView.textView.contentInset = contentInset
            self.missionInputView.textView.scrollIndicatorInsets = contentInset
            
            if let selectedRange = self.missionInputView.textView.selectedTextRange {
                let cursorRect = self.missionInputView.textView.caretRect(for: selectedRange.start)
                self.missionInputView.textView.scrollRectToVisible(cursorRect, animated: false)
            }
        }
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        missionInputView.textView.contentInset = .zero
        missionInputView.textView.scrollIndicatorInsets = .zero
    }
}

#Preview("결과 화면 확인용") {
    AppDIContainer.shared.makeAIMissionViewController()
}
