//
//  MissionCompleteViewController.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class MissionCompleteViewController: BaseViewController<MissionCompleteViewModel> {
    
    // MARK: - UI Components
    
    private let mainView = MissionCompleteView()
    
    // MARK: - Properties
    
    var initialImage: UIImage?
    
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
    
    private let completeButtonTapSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Init
    
    init(viewModel: MissionCompleteViewModel) {
        super.init(viewModel: viewModel, diContainer: AppDIContainer.shared)
        self.hidesBottomBarWhenPushed = true
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
            
            self.mainView.startFloatingAnimation { }
            
            print("화면 진입 -> 자동으로 인증 프로세스 시작")
            self.didTapCompleteButton()
        }
    }
    
    @objc
    private func didTapCompleteButton() {
        completeButtonTapSubject.send(())
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: MissionCompleteViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = MissionCompleteViewModel.Input(
            viewDidAppear: viewDidAppearSubject.eraseToAnyPublisher(),
            completeButtonTap: completeButtonTapSubject.eraseToAnyPublisher()
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
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    print("MissionCompleteVC: 인증 진행 중..")
                }
            }
            .store(in: &cancellables)
        
        output.event
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .success:
                    print("인증 완료! 이전 화면으로 이동합니다.")
                    self?.navigationController?.popViewController(animated: true)
                    
                case .failure(let errorMessage):
                    print("인증 실패: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
    }
}
