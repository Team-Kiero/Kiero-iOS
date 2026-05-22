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
    
    // MARK: - Coordinator Action
    
    var onClose: (() -> Void)?
    var onShowLoading: (() -> Void)?
    var onHideLoading: (() -> Void)?
    var onMissionCreated: (() -> Void)?
    var onSelectEndDate: ((Date, @escaping (Date) -> Void) -> Void)?
    
    // MARK: - Properties
    
    var isAnalysisDone: Bool = false {
        didSet {
            updateViewStatus()
            
            if isAnalysisDone {
                missionResultView.deadlineView.dateLabel.text =
                    currentSelectedDate.toFullDateString
            }
        }
    }
    
    var onMissionAdded: ((Mission) -> Void)?
    
    private var currentSelectedDate: Date = Date()
    
    private var suggestedMissions: [SuggestedMissionDTO] = []
    private var currentIndex: Int = 0
    private var editedMissions: [Int: Mission] = [:]
    
    private var isAllMissionsViewed: Bool = false {
        didSet {
            updateButtonState(text: "")
        }
    }
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(
        type: .close(title: "알림장 미션 추가")
    )
    
    private let missionInputView = AIMissionInputView()
    
    private let missionResultView = AIMissionResultView().then {
        $0.isHidden = true
    }
    
    private let addMissionButton = CTAButton(
        style: .main,
        size: .h49
    ).then {
        $0.configure(title: "분석하고 미션추가하기")
    }
    
    // MARK: - Life Cycle
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        missionResultView.deadlineView.dateLabel.text =
            currentSelectedDate.toFullDateString
        
        updateButtonState(text: "")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            NotificationCenter.default.post(
                name: .hideTabBar,
                object: false
            )
            
            NotificationCenter.default.post(
                name: .hideNavigationBar,
                object: false
            )
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    override func setUI() {
        view.addSubviews(
            navigationBar,
            missionInputView,
            missionResultView,
            addMissionButton
        )
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
        addMissionButton.addTarget(
            self,
            action: #selector(didTapBottomButton),
            for: .touchUpInside
        )
        
        missionResultView.onDeadlineViewTapped = { [weak self] in
            self?.presentEndDatePicker()
        }
        
        navigationBar.leftButtonAction = { [weak self] in
            guard let self else { return }
            
            if self.isAnalysisDone {
                self.isAnalysisDone = false
            } else {
                self.onClose?()
            }
        }
        
        missionInputView.onTextChanged = { [weak self] text in
            self?.updateButtonState(text: text)
        }
        
        missionResultView.pagingHeader.onLeftButtonTapped = {
            [weak self] in
            
            self?.saveCurrentState()
            self?.currentIndex -= 1
            
            self?.displayMission(
                at: self?.currentIndex ?? 0,
                direction: .right
            )
        }
        
        missionResultView.pagingHeader.onRightButtonTapped = {
            [weak self] in
            
            guard let self else { return }
            
            self.saveCurrentState()
            self.currentIndex += 1
            
            if self.currentIndex == self.suggestedMissions.count - 1 {
                self.isAllMissionsViewed = true
            }
            
            self.displayMission(
                at: self.currentIndex,
                direction: .left
            )
        }
        
        missionResultView.onSwipeLeft = { [weak self] in
            guard let self else { return }
            guard self.currentIndex < self.suggestedMissions.count - 1 else {
                return
            }
            
            self.saveCurrentState()
            self.currentIndex += 1
            
            if self.currentIndex == self.suggestedMissions.count - 1 {
                self.isAllMissionsViewed = true
            }
            
            self.displayMission(
                at: self.currentIndex,
                direction: .left
            )
        }
        
        missionResultView.onSwipeRight = { [weak self] in
            guard let self else { return }
            guard self.currentIndex > 0 else { return }
            
            self.saveCurrentState()
            self.currentIndex -= 1
            
            self.displayMission(
                at: self.currentIndex,
                direction: .right
            )
        }
    }
    
    // MARK: - Bind
    
    override func bindViewModel() {
        guard let viewModel else { return }
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                
                if isLoading {
                    guard !self.isAnalysisDone else { return }
                    self.onShowLoading?()
                } else {
                    self.onHideLoading?()
                }
            }
            .store(in: &cancellables)
        
        viewModel.suggestionResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] missions in
                guard let self else { return }
                guard !missions.isEmpty else { return }
                
                self.suggestedMissions = missions
                self.currentIndex = 0
                self.isAnalysisDone = true
                self.isAllMissionsViewed = (missions.count <= 1)
                
                self.displayMission(at: 0)
            }
            .store(in: &cancellables)
        
        viewModel.bulkCreateSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                
                print("✅ bulkCreateSuccess received")
                print("✅ onMissionCreated is nil:", self.onMissionCreated == nil)
                Toast.show(
                    message: "미션이 등록되었어요.",
                    bottomInset: 88
                )
                
                self.onMissionCreated?()
            }
            .store(in: &cancellables)
        
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
                
                self.addMissionButton.isEnabled = true
                self.onHideLoading?()
                
                Toast.show(
                    message: message,
                    bottomInset: 40
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Action
    
    @objc
    private func didTapBottomButton() {
        if !isAnalysisDone {
            view.endEditing(true)
            
            guard let text = missionInputView.textView.text,
                  !text.isEmpty else {
                return
            }
            
            addMissionButton.isEnabled = false
            viewModel?.analyzeNotice(text: text)
            
        } else {
            addMissionButton.isEnabled = false
            saveActualMission()
        }
    }
    
    // MARK: - Private
    
    private func saveCurrentState() {
        let name = missionResultView.nameTextField.text ?? ""
        let reward = missionResultView.selectedReward
        let date = currentSelectedDate.toString(format: "yyyy-MM-dd")
        
        editedMissions[currentIndex] = Mission(
            name: name,
            reward: reward,
            dueAt: date
        )
    }
    
    private func saveActualMission() {
        saveCurrentState()
        
        let finalMissions = (0..<suggestedMissions.count)
            .compactMap { index -> Mission? in
                
                if let edited = editedMissions[index] {
                    return edited
                }
                
                let original = suggestedMissions[index]
                
                return Mission(
                    name: original.name,
                    reward: original.reward,
                    dueAt: original.dueAt
                )
            }
        
        viewModel?.createBulkMissions(
            missions: finalMissions
        )
    }
    
    private func displayMission(
        at index: Int,
        direction: UISwipeGestureRecognizer.Direction? = nil
    ) {
        let total = suggestedMissions.count
        let mission = suggestedMissions[index]
        
        missionResultView.pagingHeader.configure(
            title: "미션 \(index + 1)/\(total)",
            isLeftEnabled: index > 0,
            isRightEnabled: index < total - 1
        )
        
        if let edited = editedMissions[index] {
            missionResultView.nameTextField.text = edited.name
            
            currentSelectedDate = edited.dueAt.toDate(format: "yyyy-MM-dd") ?? Date()
            
            missionResultView.updateReward(to: edited.reward)
            
        } else {
            missionResultView.nameTextField.text = mission.name
            
            currentSelectedDate = mission.dueAt.toDate(format: "yyyy-MM-dd") ?? Date()
            
            missionResultView.updateReward(to: mission.reward)
        }
        
        missionResultView.deadlineView.dateLabel.text =
            currentSelectedDate.toFullDateString
        
        guard let direction else { return }
        
        let contentContainer = missionResultView.contentContainer
        
        let offset: CGFloat = direction == .left ? 60 : -60
        
        contentContainer.transform = CGAffineTransform(translationX: offset, y: 0)
        
        contentContainer.alpha = 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            contentContainer.transform = .identity
            contentContainer.alpha = 1
        }
    }
    
    private func updateButtonState(text: String) {
        if !isAnalysisDone {
            let isValid = text.count >= 10 && text.count <= 1000
            addMissionButton.isEnabled = isValid
            addMissionButton.alpha = isValid ? 1.0 : 0.5
            addMissionButton.configure(title: "분석하고 미션추가하기")
        } else {
            addMissionButton.isEnabled = isAllMissionsViewed
            addMissionButton.alpha = isAllMissionsViewed ? 1.0 : 0.5
            
            let title = isAllMissionsViewed ? "저장하기" : "마지막 미션까지 확인해주세요"
            addMissionButton.configure(title: title)
        }
    }
    
    private func updateViewStatus() {
        missionInputView.isHidden = isAnalysisDone
        missionResultView.isHidden = !isAnalysisDone
        
        updateButtonState(text: missionInputView.textView.text)
    }
    
    private func presentEndDatePicker() {
        onSelectEndDate?(currentSelectedDate) { [weak self] selectedDate in
            guard let self else { return }
            self.currentSelectedDate = selectedDate
            self.missionResultView.deadlineView.dateLabel.text = selectedDate.toFullDateString
        }
    }
    
    func setAnalysisStatus(isDone: Bool) {
        isAnalysisDone = isDone
    }
    
    // MARK: - Keyboard
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let textViewFrameInView = missionInputView.convert(missionInputView.textView.frame, to: view)
        let textViewMinY = textViewFrameInView.minY
        let availableHeight = view.frame.height - keyboardHeight - textViewMinY
        
        missionInputView.updateMaxHeight(min(508, max(376, availableHeight)))
        missionInputView.setKeyboardInset(bottom: 65)
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        missionInputView.setKeyboardInset(bottom: 0)
        missionInputView.updateMaxHeight(508)
    }
}
