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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                make.bottom.equalTo(addMissionButton.snp.top).offset(-10)
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
    }
    
    private func updateViewStatus() {
        missionInputView.isHidden = isAnalysisDone
        missionResultView.isHidden = !isAnalysisDone
        
        let buttonTitle = isAnalysisDone ? "저장하기" : "분석하고 미션추가하기"
        addMissionButton.configure(title: buttonTitle)
    }
    
    @objc
    private func didTapBottomButton() {
        if !isAnalysisDone {
            // TODO: 로딩VC 진입
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
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd.(E)"
            self.missionResultView.deadlineView.dateLabel.text = formatter.string(from: selectedDate)
        }
        
        endDateVC.modalPresentationStyle = .overFullScreen
        self.present(endDateVC, animated: false)
    }
    
    func setAnalysisStatus(isDone: Bool) {
        self.isAnalysisDone = isDone
    }
}

#Preview("결과 화면 확인용") {
    AppDIContainer.shared.makeAIMissionViewController()
}
