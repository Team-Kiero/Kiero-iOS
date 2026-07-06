//
//  DailyJourneyViewController.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/13/26.
//

import UIKit
import Combine
import UserNotifications

final class DailyJourneyViewController: BaseViewController<DailyJourneyViewModel> {
    
    // MARK: - Properties
    
    var makeDailyJourneyMapVC: (() -> DailyJourneyMapViewController)?
    var makeGiveFireStoneVC: ((Int) -> GiveFireStoneViewController)?
    
    private let mainView = DailyJourneyView()
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let viewWillDisappearSubject = PassthroughSubject<Void, Never>()
    private let nextButtonTapSubject = PassthroughSubject<Void, Never>()
    private let verifyButtonTapSubject = PassthroughSubject<Void, Never>()
    private let skipConfirmSubject = PassthroughSubject<Void, Never>()
    private var previousHasSchedule: Bool?
    private var hasCheckedNotification = false
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.send(())
        checkNotificationPermissionIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearSubject.send(())
    }
    
    override func addTarget() {
        super.addTarget()
        mainView.onNextJourneyTap = { [weak self] in
            self?.didTapNextButton()
        }
        mainView.verifyPhotoButton.addTarget(self, action: #selector(didTapVerifyButton), for: .touchUpInside)
        
        mainView.onMapButtonTap = { [weak self] in
            guard let mapVC = self?.makeDailyJourneyMapVC?() else { return }
            mapVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    override func bind(viewModel: DailyJourneyViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = DailyJourneyViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            viewWillDisappear: viewWillDisappearSubject.eraseToAnyPublisher(),
            nextJourneyButtonTap: nextButtonTapSubject.eraseToAnyPublisher(),
            verifyButtonTap: verifyButtonTapSubject.eraseToAnyPublisher(),
            skipConfirmTap: skipConfirmSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.viewData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewData in
                guard let self else { return }
                
                let wasEmpty = self.previousHasSchedule == false
                let nowHasSchedule = viewData.isTimeViewActive
                let shouldAnimate = wasEmpty && nowHasSchedule
                
                self.mainView.updateData(with: viewData, animated: shouldAnimate)
                self.previousHasSchedule = nowHasSchedule
            }
            .store(in: &cancellables)
        
        output.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func didTapNextButton() {
        nextButtonTapSubject.send(())
    }
    
    @objc
    private func didTapVerifyButton() {
        verifyButtonTapSubject.send(())
    }
    
    private func handleRoute(_ route: DailyJourneyRoute) {
        switch route {
        case .showNextJourneyDialogBox:
            showNextJourneyDialog()

        case .showEndJourneyDialogBox:
            showEndJourneyDialog()

        case .showCamera:
            openCamera()
            
        case .tryLightFire:
            let stoneCount = self.viewModel?.currentEarnedStoneCount ?? 0
            guard let vc = self.makeGiveFireStoneVC?(stoneCount) else { return }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showNextJourneyDialog() {
        let dialogBox = DialogBox()
        dialogBox.configure(state: .nextJourney)
        dialogBox.onTapConfirm = { [weak self] in
            dialogBox.dismiss()
            self?.skipConfirmSubject.send(())
        }
        dialogBox.show(in: self)
    }

    private func showEndJourneyDialog() {
        let dialogBox = DialogBox()
        dialogBox.configure(state: .endJourney)
        dialogBox.onTapConfirm = { [weak self] in
            dialogBox.dismiss()
            self?.skipConfirmSubject.send(())
        }
        dialogBox.show(in: self)
    }

    private func checkNotificationPermissionIfNeeded() {
        guard !hasCheckedNotification else { return }
        hasCheckedNotification = true

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            DispatchQueue.main.async {
                self?.showNotificationRequestDialog()
            }
        }
    }

    private func showNotificationRequestDialog() {
        let dialogBox = DialogBox()
        dialogBox.configure(state: .notificationRequest)
        dialogBox.onTapConfirm = {
            dialogBox.dismiss()
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                Task {
                    let body = NotificationSettingsRequest(pushNotificationEnabled: true)
                    let _: EmptyResponse? = try? await BaseService.shared.request(
                        endPoint: .updateNotificationSettings,
                        body: body
                    )
                }
            }
        }
        dialogBox.show(in: self)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("카메라를 사용할 수 없습니다.")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        
        self.present(picker, animated: true)
    }
    
    private func moveToMissionCompleteView(with image: UIImage) {
        let completeViewModel = MissionCompleteViewModel()
        completeViewModel.capturedImage = image
        completeViewModel.receivedStoneType = self.viewModel?.currentStoneType
        completeViewModel.scheduleDetailId = self.viewModel?.currentScheduleDetailId
        
        let completeVC = MissionCompleteViewController(viewModel: completeViewModel)
        completeVC.initialImage = image
        
        self.navigationController?.pushViewController(completeVC, animated: true)
    }
}

extension DailyJourneyViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let capturedImage = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        picker.dismiss(animated: false) { [weak self] in
            self?.moveToMissionCompleteView(with: capturedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension DailyJourneyViewController: TabBarReselectRefreshable {
    func refreshOnTabReselect() {
        viewWillAppearSubject.send(())
    }
}
