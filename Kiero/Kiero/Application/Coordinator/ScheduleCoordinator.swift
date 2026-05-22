//
//  ScheduleCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import UIKit

final class ScheduleCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    
    init(
        navigationController: UINavigationController,
        factory: ViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() -> UIViewController {
        let vc = factory.makeScheduleViewController()
        
        vc.onAddScheduleTap = { [weak self, weak vc] isFireLit, schedules, targetDate in
            guard let self, let vc else { return }
            
            self.showAddSchedule(
                from: vc,
                isFireLit: isFireLit,
                schedules: schedules,
                targetDate: targetDate
            )
        }
        
        vc.scheduleChildVC.onEditScheduleTap = { [weak self, weak vc] schedule, bottomSheet in
            guard let self, let vc else { return }
            
            self.showEditSchedule(
                from: vc,
                schedule: schedule,
                bottomSheet: bottomSheet
            )
        }
        
        return vc
    }
    
    private func showAddSchedule(
        from viewController: ScheduleViewController,
        isFireLit: Bool,
        schedules: [Schedule],
        targetDate: Date
    ) {
        let addScheduleVC = factory.makeAddScheduleViewController(
            isFireLit: isFireLit,
            scheduleList: schedules
        )
        
        addScheduleVC.baseDate = targetDate
        
        addScheduleVC.onScheduleAdded = { [weak viewController] _, targetDate in
            viewController?.updateReferenceDate(targetDate)
        }
        
        let nav = UINavigationController(rootViewController: addScheduleVC)
        nav.modalPresentationStyle = .fullScreen
        
        viewController.present(nav, animated: true)
    }
    
    private func showEditSchedule(
        from viewController: ScheduleViewController,
        schedule: Schedule,
        bottomSheet: DetailBottomSheet
    ) {
        let editVC = factory.makeEditScheduleViewController(schedule: schedule)
        editVC.modalPresentationStyle = .overFullScreen
        
        editVC.onEditConfirmed = { [weak viewController] request, selectedDate, _, completion in
            viewController?.viewModel?.editSchedule(
                scheduleId: schedule.id,
                selectedDate: selectedDate,
                isRecurring: schedule.isRecurring,
                request: request,
                completion: completion
            )
        }
        
        bottomSheet.dismiss(animated: false) {
            viewController.present(editVC, animated: true)
        }
    }
}
