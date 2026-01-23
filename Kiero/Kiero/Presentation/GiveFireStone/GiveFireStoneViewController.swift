//
//  GiveFireStoneViewController.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class GiveFireStoneViewController: BaseViewController<GiveFireStoneViewModel> {
    
    // MARK: - UI Components
    
    private let entryView = GiveFireStoneView()
    
    private let processView = GiveFireStoneAnimationView().then {
        $0.alpha = 0
        $0.isHidden = true
    }
    
    private let resultView = GiveFireStoneResultView().then {
        $0.alpha = 0
        $0.isHidden = true
    }
    
    private let giveButtonTapSubject = PassthroughSubject<Void, Never>()
    private let processViewDidAppearSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        self.hidesBottomBarWhenPushed = true
        super.viewDidLoad()
        view.backgroundColor = .kBlack
        entryView.configure(count: viewModel?.earnedStoneCount ?? 0)
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        view.addSubviews(entryView, processView, resultView)
        
        entryView.didTapGiveButton = { [weak self] in
            self?.giveButtonTapSubject.send(())
        }
        
        entryView.didTapBackButton = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        resultView.didTapClose = { [weak self] in
            self?.navigateToDailyJourney()
        }
    }
    
    override func setLayout() {
        [entryView, processView, resultView].forEach { view in
            view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: GiveFireStoneViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = GiveFireStoneViewModel.Input(
            didTapGiveButton: giveButtonTapSubject.eraseToAnyPublisher(),
            processViewDidAppear: processViewDidAppearSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.showProcessView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.animateToProcessView()
            }
            .store(in: &cancellables)
        
        output.showResultView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (coin, stones) in
                guard let self else { return }
                
                self.processView.playAnimation(stones: stones) { [weak self] in
                    guard let self else { return }
                    
                    self.resultView.configure(coin: coin, stones: stones)
                    self.animateToResultView()
                }
            }
            .store(in: &cancellables)
        
        
        output.showError
            .receive(on: DispatchQueue.main)
            .sink { message in
                print("message: \(message)")    }
            .store(in: &cancellables)
    }
    
    private func navigateToDailyJourney() {
        if let navigationController = self.presentingViewController as? UINavigationController {
            self.dismiss(animated: true) {
                navigationController.popToRootViewController(animated: true)
            }
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Animation Logic
    
    private func animateToProcessView() {
        processView.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.entryView.alpha = 0
            self.processView.alpha = 1
        }) { _ in
            self.entryView.isHidden = true
            self.processViewDidAppearSubject.send(())
        }
    }
    
    private func animateToResultView() {
        resultView.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.processView.alpha = 0
            self.resultView.alpha = 1
        }) { _ in
            self.processView.isHidden = true
            self.resultView.playGif()
        }
    }
}
