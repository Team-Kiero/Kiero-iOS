//
//  AppUpdateAlertPresenter.swift
//  Kiero
//

import UIKit

@MainActor
final class AppUpdateAlertPresenter {

    private weak var window: UIWindow?
    private var isUpdateAlertPresented = false

    func checkForUpdate(in window: UIWindow?) {
        guard let window else { return }

        self.window = window

        Task { [weak self] in
            guard let self else { return }

            let updateType = await AppUpdateManager.shared.checkForUpdate()
            handleUpdate(updateType)
        }
    }

    private func handleUpdate(_ updateType: AppUpdateType) {
        switch updateType {
        case .none:
            break

        case .optional:
            showOptionalUpdateAlert()

        case .required:
            showRequiredUpdateAlert()
        }
    }

    private func showOptionalUpdateAlert() {
        guard !isUpdateAlertPresented else { return }
        guard let viewController = topViewController() else { return }

        isUpdateAlertPresented = true

        let alert = UIAlertController(
            title: "새로운 업데이트",
            message: "새로운 버전이 출시되었어요.\n업데이트하시겠어요?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "나중에", style: .cancel) { [weak self] _ in
            self?.isUpdateAlertPresented = false
        })

        alert.addAction(UIAlertAction(title: "업데이트", style: .default) { [weak self] _ in
            guard let self else { return }

            isUpdateAlertPresented = false
            openAppStore(shouldRetryRequiredAlert: false)
        })

        viewController.present(alert, animated: true)
    }

    private func showRequiredUpdateAlert() {
        guard !isUpdateAlertPresented else { return }
        guard let viewController = topViewController() else { return }

        isUpdateAlertPresented = true

        let alert = UIAlertController(
            title: "필수 업데이트",
            message: "서비스 이용을 위해\n최신 버전으로 업데이트해 주세요.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "업데이트", style: .default) { [weak self] _ in
            guard let self else { return }

            isUpdateAlertPresented = false
            openAppStore(shouldRetryRequiredAlert: true)
        })

        viewController.present(alert, animated: true)
    }

    private func openAppStore(shouldRetryRequiredAlert: Bool) {
        UIApplication.shared.open(Config.appStoreURL, options: [:]) { [weak self] didOpen in
            guard !didOpen else { return }

            Task { @MainActor [weak self] in
                guard let self else { return }

#if DEBUG
                print("❌ [AppUpdateAlertPresenter] App Store 열기 실패")
#endif

                guard shouldRetryRequiredAlert else { return }

                try? await Task.sleep(nanoseconds: 300_000_000)
                showRequiredUpdateAlert()
            }
        }
    }

    private func topViewController(from viewController: UIViewController? = nil) -> UIViewController? {
        let current = viewController ?? window?.rootViewController

        if let navigationController = current as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }

        if let tabBarController = current as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }

        if let presentedViewController = current?.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        return current
    }
}
