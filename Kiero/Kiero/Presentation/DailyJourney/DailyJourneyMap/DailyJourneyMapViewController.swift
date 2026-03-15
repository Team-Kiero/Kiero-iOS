//
//  DailyJourneyMapViewController.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/4/26.
//

import Combine
import SwiftUI
import UIKit


final class DailyJourneyMapViewController: BaseViewController<DailyJourneyMapViewModel> {
    
    // MARK: - Properties
    
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private var hostingController: UIHostingController<DailyJourneyMapView>?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        viewWillAppearSubject.send()
    }
    
    // MARK: - Setup
    
    private func setupHostingController() {
        guard let viewModel = self.viewModel else { return }
        
        let swiftUIView = DailyJourneyMapView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: swiftUIView)
        hosting.view.backgroundColor = .clear
        hosting.view.clipsToBounds = true
        
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        hosting.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.hostingController = hosting
    }
    
    // MARK: - Bind
    
    override func bind(viewModel: DailyJourneyMapViewModel) {
        super.bind(viewModel: viewModel)
        
        let input = DailyJourneyMapViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            confirmButtonTap: viewModel.confirmButtonTapSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.dismiss
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}
