//
//  MissionViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class MissionViewController: BaseViewController<MissionViewModel> {
    
    // MARK: - UI Components
    
    private let emptyView = EmptyView(text: "등록된 미션이 없어요.\n우측 하단 버튼을 눌러 미션을 추가해보세요!")
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Setup Methods
    
    override func setStyle() {
        view.backgroundColor = .gray900
    }
    
    override func setUI() {
        view.addSubview(emptyView)
    }
    
    override func setLayout() {
        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

#Preview {
    AppDIContainer.shared.makeMissionViewController()
}
