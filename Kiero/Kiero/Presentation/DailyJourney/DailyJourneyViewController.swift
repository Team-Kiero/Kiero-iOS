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
        
        mainView.goToNextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        mainView.verifyPhotoButton.addTarget(self, action: #selector(didTapVerifyButton), for: .touchUpInside)
    }
    
    override func bind(viewModel: DailyJourneyViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = DailyJourneyViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            nextJourneyButtonTap: nextButtonTapSubject.eraseToAnyPublisher(),
            verifyButtonTap: verifyButtonTapSubject.eraseToAnyPublisher()
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
            print("LOG: 다음 여정 팝업 띄우기")
        case .showCamera:
            print("LOG: 인증 카메라 화면으로 이동")
        }
    }
}
