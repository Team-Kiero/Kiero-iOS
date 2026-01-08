//
//  TestViewController.swift
//  Kiero
//
//  Created by 정윤아 on 1/9/26.
//

import UIKit
import SnapKit

final class TestViewController: UIViewController {

    private let missionBox = MissionBoxParentView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        view.addSubview(missionBox)
        missionBox.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
    }
}


