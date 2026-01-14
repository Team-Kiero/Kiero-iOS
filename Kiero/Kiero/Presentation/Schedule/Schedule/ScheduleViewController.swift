//
//  ScheduleViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import UIKit
import Combine

import SnapKit
import Then

class ScheduleViewController: BaseViewController<ScheduleViewModel> {
    
    // MARK: - UI Components
    
    private let scheduleView = ScheduleView()
    private let missionView = ScheduleView()
    
    private lazy var segmentedControl = SegmentedControl(
        titles: ["일정", "미션"],
        contentViews: [scheduleView, missionView]
    )
    
    private let floatingButton = FloatingButton(type: .schedule)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAction()
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        view.backgroundColor = .gray900
    }
    
    override func setUI() {
        view.addSubviews(segmentedControl, floatingButton)
    }
    
    override func setLayout() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(93)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(31)
            $0.bottom.equalToSuperview().inset(119)
        }
    }
    
    override func bind(viewModel: ScheduleViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = ScheduleViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.schedules
            .receive(on: RunLoop.main)
            .sink { [weak self] schedules in
                self?.scheduleView.updateSchedules(schedules)
            }
            .store(in: &cancellables)
    }
    
    private func setAction() {
        floatingButton.tapAction = { [weak self] in
            guard let self = self else { return }
                
            let addScheduleVC = AppDIContainer.shared.makeAddScheduleViewController()
            let navigationController = UINavigationController(rootViewController: addScheduleVC)
            
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

#Preview {
    AppDIContainer.shared.makeScheduleViewController()
}
