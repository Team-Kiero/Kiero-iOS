//
//  DailyJourneyViewController.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/13/26.
//

import UIKit
import Combine

final class DailyJourneyViewController: BaseViewController<DailyJourneyViewModel> {
    
    // MARK: - Properties
    
    private let mainView = DailyJourneyView()
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let nextButtonTapSubject = PassthroughSubject<Void, Never>()
    private let verifyButtonTapSubject = PassthroughSubject<Void, Never>()
    private let skipConfirmSubject = PassthroughSubject<Void, Never>()
    
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
    }
    
    override func addTarget() {
        super.addTarget()
        mainView.onNextJourneyTap = { [weak self] in
            self?.didTapNextButton()
        }
        mainView.verifyPhotoButton.addTarget(self, action: #selector(didTapVerifyButton), for: .touchUpInside)
    }
    
    override func bind(viewModel: DailyJourneyViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = DailyJourneyViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            nextJourneyButtonTap: nextButtonTapSubject.eraseToAnyPublisher(),
            verifyButtonTap: verifyButtonTapSubject.eraseToAnyPublisher(),
            skipConfirmTap: skipConfirmSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.viewData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewData in
                self?.mainView.updateData(with: viewData)
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
            print("다음 여정 다이어로그")
            
        case .showCamera:
            openCamera()
        }
    }
    
    private func showNextJourneyDialog() {
        self.view.showDialog(state: .nextJourney) { [weak self] in
            print("유저가 다음 여정으로 넘어가기를 확정")
            // TODO: ViewModel의 다음 여정 로직 연결
            self?.skipConfirmSubject.send(())
        }
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
