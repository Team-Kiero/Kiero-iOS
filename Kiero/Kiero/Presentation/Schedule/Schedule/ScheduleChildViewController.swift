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
    
    // MARK: - Properties
    
    override var viewModel: ScheduleViewModel? {
        didSet {
            guard let vm = viewModel else { return }
            self.bind(viewModel: vm)
        }
    }
    
    private let scheduleView = ScheduleView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = scheduleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: ScheduleViewModel) {
        cancellables.removeAll()
        
        let input = ScheduleViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.schedules
            .receive(on: RunLoop.main)
            .sink { [weak self] (schedules: [Schedule]) in
                self?.scheduleView.updateSchedules(schedules)
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
            .store(in: &cancellables)
    }
}
