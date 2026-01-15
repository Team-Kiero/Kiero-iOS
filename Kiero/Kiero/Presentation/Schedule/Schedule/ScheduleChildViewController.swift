//
//  ScheduleChildViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit
import Combine

import SnapKit
import Then

final class ScheduleChildViewController: BaseViewController<ScheduleViewModel> {
    
    private let scheduleView = ScheduleView()
    
    override func loadView() {
        self.view = scheduleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
