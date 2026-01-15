//
//  MissionCompleteViewController.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import UIKit
import Combine

import SnapKit
import Then

final class MissionCompleteViewController: BaseViewController<MissionCompleteViewModel> {
    
    // MARK: - UI Components
    
    private let mainView = MissionCompleteView()
    
    // MARK: - Properties
    
    var initialImage: UIImage?
    var scheduleDetailId: Int = 1
    
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    
    init(viewModel: MissionCompleteViewModel) {
        super.init(viewModel: viewModel, diContainer: AppDIContainer.shared)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = initialImage {
            mainView.backgroundImageView.image = image
            print("[DEBUG] viewDidLoad에서 이미지 즉시 설정 완료")
        } else {
            print("[DEBUG] initialImage가 nil. DailyJourneyVC 확인")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearSubject.send(())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.mainView.startFloatingAnimation {
                self.moveToPreviousScreen()
            }
        }
    }
    
    // MARK: - Navigation
    
    private func moveToPreviousScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Binding
    
    override func bind(viewModel: MissionCompleteViewModel) {
        super.bind(viewModel: viewModel)
        
        viewModel.scheduleDetailId = self.scheduleDetailId
        
        let input = MissionCompleteViewModel.Input(
            viewDidAppear: viewDidAppearSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.missionData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.mainView.configure(
                    capturedImage: self?.initialImage,
                    rewardImage: data.stoneImage,
                    message: data.message,
                    keyword: data.highlightKeyword
                )
            }
            .store(in: &cancellables)
    }
}
