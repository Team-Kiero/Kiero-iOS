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
    
    private var suggestedMissions: [SuggestedMissionDTO] = []
    private var currentIndex: Int = 0
    private var editedMissions: [Int: Mission] = [:]
    
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
        
        missionResultView.pagingHeader.onLeftButtonTapped = { [weak self] in
            self?.saveCurrentState()
            self?.currentIndex -= 1
            self?.displayMission(at: self?.currentIndex ?? 0)
        }
        
        missionResultView.pagingHeader.onRightButtonTapped = { [weak self] in
            self?.saveCurrentState()
            self?.currentIndex += 1
            self?.displayMission(at: self?.currentIndex ?? 0)
        }
    }
    
    override func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    if self.isAnalysisDone { return }
                    
                    let loadingVC = LoadingViewController(viewModel: LoadingViewModel(), diContainer: AppDIContainer.shared)
                    loadingVC.modalPresentationStyle = .overFullScreen
                    self.present(loadingVC, animated: false)
                } else {
                    if let presented = self.presentedViewController as? LoadingViewController {
                        presented.dismiss(animated: false)
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.suggestionResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] missions in
                guard let self = self, !missions.isEmpty else { return }
                self.suggestedMissions = missions
                self.currentIndex = 0
                self.isAnalysisDone = true
                self.displayMission(at: 0)
            }
            .store(in: &cancellables)
        
        viewModel.bulkCreateSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func didTapBottomButton() {
        if !isAnalysisDone {
            self.view.endEditing(true)
            guard let text = missionInputView.textView.text, !text.isEmpty else { return }
            viewModel?.analyzeNotice(text: text)
        } else {
            saveActualMission()
        }
    }
    
    private func saveCurrentState() {
        let name = missionResultView.nameTextField.text ?? ""
        let reward = missionResultView.selectedReward
        let date = currentSelectedDate.toString(format: "yyyy-MM-dd")
        
        editedMissions[currentIndex] = Mission(name: name, reward: reward, dueAt: date)
    }
    
    private func saveActualMission() {
        saveCurrentState()
        
        let finalMissions = (0..<suggestedMissions.count).compactMap { index -> Mission? in
            if let edited = editedMissions[index] { return edited }
            let original = suggestedMissions[index]
            return Mission(
                name: original.name,
                reward: original.reward,
                dueAt: original.dueAt
            )
        }
        
        viewModel?.createBulkMissions(missions: finalMissions)
    }
    
    private func displayMission(at index: Int) {
        let total = suggestedMissions.count
        let mission = suggestedMissions[index]
        
        missionResultView.pagingHeader.configure(
            title: "미션 \(index + 1)/\(total)",
            isLeftEnabled: index > 0,
            isRightEnabled: index < total - 1
        )
        
        if let edited = editedMissions[index] {
            missionResultView.nameTextField.text = edited.name
            self.currentSelectedDate = edited.dueAt.toDate(format: "yyyy-MM-dd") ?? Date()
            missionResultView.updateReward(to: edited.reward)
        } else {
            missionResultView.nameTextField.text = mission.name
            self.currentSelectedDate = mission.dueAt.toDate(format: "yyyy-MM-dd") ?? Date()
            missionResultView.updateReward(to: mission.reward)
        }
        
        missionResultView.deadlineView.dateLabel.text = currentSelectedDate.toFullDateString
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
