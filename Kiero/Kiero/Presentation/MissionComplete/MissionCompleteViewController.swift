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
    
    private var isAnimationFinished = false
    private var isApiSuccess = false
    
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
            
            self.mainView.startFloatingAnimation { [weak self] in
                print("✨ 애니메이션 종료 (4초)")
                self?.isAnimationFinished = true
                self?.checkAndPopViewController()
            }
            
            print("🚀 화면 진입 -> 인증 프로세스 시작")
            self.didTapCompleteButton()
        }
    }
    
    // MARK: - Logic
    
    private func didTapCompleteButton() {
        completeButtonTapSubject.send(())
    }
    
    private func checkAndPopViewController() {
        if isAnimationFinished && isApiSuccess {
            print("✅ 모든 조건 충족 (애니메이션 끝 + 인증 성공) -> 화면 이동")
            self.navigationController?.popViewController(animated: true)
        } else {
            print("⏳ 대기 중... (애니메이션 완료: \(isAnimationFinished), API 성공: \(isApiSuccess))")
        }
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
                guard let self = self else { return }
                
                switch event {
                case .success:
                    print("🎉 서버 인증 성공~~ 룰루~~")
                    self.isApiSuccess = true
                    self.checkAndPopViewController()
                    
                case .failure(let errorMessage):
                    print("❌ 인증 실패: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
    }
}
