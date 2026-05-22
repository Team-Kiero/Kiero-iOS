//
//  AIMissionCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/21/26.
//

import UIKit

final class AIMissionCoordinator: Coordinator {

    private let presentingViewController: UIViewController
    private let factory: ViewControllerFactory

    init(
        presentingViewController: UIViewController,
        factory: ViewControllerFactory
    ) {
        self.presentingViewController = presentingViewController
        self.factory = factory
    }

    func start() -> UIViewController {
        let vc = factory.makeAIMissionViewController()

        vc.onClose = { [weak vc] in
            NotificationCenter.default.post(name: .hideTabBar, object: false)
            NotificationCenter.default.post(name: .hideNavigationBar, object: false)

            if let presented = vc?.presentedViewController {
                presented.dismiss(animated: false) {
                    vc?.dismiss(animated: true)
                }
            } else {
                vc?.dismiss(animated: true)
            }
        }

        vc.onSelectEndDate = { [weak vc] currentDate, completion in
            guard let vc else { return }
            self.showEndDatePicker(
                from: vc,
                currentDate: currentDate,
                completion: completion
            )
        }

        vc.onShowLoading = { [weak vc] in
            guard let vc else { return }
            self.showLoading(from: vc)
        }

        vc.onHideLoading = { [weak vc] in
            vc?.presentedViewController?.dismiss(animated: false)
        }

        vc.onMissionCreated = { [weak vc] in
            NotificationCenter.default.post(name: .hideTabBar, object: false)
            NotificationCenter.default.post(name: .hideNavigationBar, object: false)

            if let presented = vc?.presentedViewController {
                presented.dismiss(animated: false) {
                    vc?.dismiss(animated: true)
                }
            } else {
                vc?.dismiss(animated: true)
            }
        }

        return vc
    }

    private func showLoading(from viewController: UIViewController) {
        let loadingVC = factory.makeLoadingViewController()
        loadingVC.modalPresentationStyle = .overFullScreen
        viewController.present(loadingVC, animated: false)
    }

    private func showEndDatePicker(
        from viewController: UIViewController,
        currentDate: Date,
        completion: @escaping (Date) -> Void
    ) {
        let vc = EndDateViewController()
        vc.setInitialDate(currentDate)
        vc.onDateSelected = { completion($0) }
        vc.modalPresentationStyle = .overFullScreen
        viewController.present(vc, animated: false)
    }
}
