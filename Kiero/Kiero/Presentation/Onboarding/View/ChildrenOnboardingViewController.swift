//
//  ChildrenOnboardingViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class ChildrenOnboardingViewController: BaseViewController<ChildrenOnboardingViewModel> {
    
    // MARK: - Properties
    
    private let nextTap = PassthroughSubject<Void, Never>()
    
    private var currentSpeech: SpeechField?
    
    private var latestItem: SpeechItem?
    
    private var currentFieldType: SpeechField.fieldType = .main
    
    // MARK: - UI Components
    
    private let storyImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let mainSF = SpeechField(type: .main)
    
    private let noSF = SpeechField(type: .no)
    
    private let startButton = CTAButton(style: .main, size: .h49).then {
        $0.configure(title: "시작해보자!")
        $0.alpha = 0
    }
    
    // MARK: - Life Cycle
    
    override func setUI() {
        view.addSubviews(
            storyImageView,
            startButton,
            mainSF
        )
        currentSpeech = mainSF
    }
    
    override func setLayout() {
        storyImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        mainSF.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.bottom).offset(-253)
        }
    }
    
    override func addTarget() {
        mainSF.onTap = {
            self.didTapNext()
        }
        
        noSF.onTap = {
            self.didTapNext()
        }
        
        startButton.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
    }
    
    override func bind(viewModel: ChildrenOnboardingViewModel) {
        super.bind(viewModel: viewModel)
        
        let output = viewModel.transform(
            input: .init(
                nextTapped: nextTap.eraseToAnyPublisher()
            )
        )
        
        output.item
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self else { return }
                self.latestItem = item
                self.storyImageView.image = item.image

                self.currentSpeech?.configure(
                    fieldType: self.currentFieldType,
                    name: item.name,
                    lines: item.lines,
                    highlightKeywords: item.highlightKeywords
                )
            }
            .store(in: &cancellables)
        
        output.fieldType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                guard let self else { return }
                self.currentFieldType = type
                
                let nextSpeech = (type == .no) ? self.noSF : self.mainSF
                
                if self.currentSpeech !== nextSpeech {
                    self.currentSpeech?.removeFromSuperview()
                    self.currentSpeech = nextSpeech
                    self.view.addSubview(nextSpeech)
                    
                    nextSpeech.snp.makeConstraints {
                        $0.leading.trailing.equalToSuperview()
                        $0.top.equalTo(self.view.snp.bottom).offset(-253)
                    }
                    
                    startButton.snp.makeConstraints {
                        $0.top.equalTo(nextSpeech.snp.bottom).offset(20)
                    }
                    
                    if let item = self.latestItem {
                        nextSpeech.configure(
                            fieldType: type,
                            name: item.name,
                            lines: item.lines,
                            highlightKeywords: item.highlightKeywords
                        )
                    }
                }
            }
            .store(in: &cancellables)
        
        output.isLast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLast in
                guard let self else { return }
                
                if isLast {
                    self.startButton.isHidden = false
                    UIView.animate(withDuration: 0.2) {
                        self.startButton.alpha = 1
                    }
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.startButton.alpha = 0
                    }, completion: { _ in
                        self.startButton.isHidden = true
                    })
                }
            }
            .store(in: &cancellables)
    }
    
    private func didTapNext() {
        nextTap.send(())
    }
    
    private func navigateToChildrenTap() {
        let tab = TabBarViewController(factory: AppDIContainer.shared, isParent: false)
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(tab)
        }
    }
    
    @objc
    private func startButtonDidTap() {
        let loadingVC = AppDIContainer.shared.makeChildLoadingViewController()
        loadingVC.modalPresentationStyle = .fullScreen
        present(loadingVC, animated: false)
        
        DispatchQueue.main.asyncAfter (deadline: .now() + 4) { [weak self] in
            self?.navigateToChildrenTap()
        }
    }
}
