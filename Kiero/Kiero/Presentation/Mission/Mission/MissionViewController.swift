//
//  MissionViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit
import Combine

import SnapKit
import Then

final class MissionViewController: BaseViewController<MissionViewModel> {
    
    // MARK: - UI Components
    
    private let emptyView = EmptyView(text: "등록된 미션이 없어요.\n우측 하단 버튼을 눌러 미션을 추가해보세요!")
    private let missionView = MissionView()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.fetchMissions()
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        view.backgroundColor = .gray900
    }
    
    override func setUI() {
        view.addSubviews(emptyView, missionView)
    }
    
    override func setLayout() {
        emptyView.snp.makeConstraints { $0.edges.equalToSuperview() }
        missionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    override func bind(viewModel: MissionViewModel) {
        super.bind(viewModel: viewModel)
        
        viewModel.$missions
            .receive(on: RunLoop.main)
            .sink { [weak self] missions in
                guard let self = self else { return }
                
                let hasData = !missions.isEmpty
                self.emptyView.isHidden = hasData
                self.missionView.isHidden = !hasData
                
                if hasData {
                    self.missionView.updateMissions(missions)
                }
            }
            .store(in: &cancellables)
    }
}

extension MissionViewController: ScrollToTopAvailable {
    func scrollToTop() {
        DispatchQueue.main.async { [weak self] in
            self?.missionView.scrollToTop()
        }
    }
}

#Preview {
    AppDIContainer.shared.makeMissionViewController()
}
