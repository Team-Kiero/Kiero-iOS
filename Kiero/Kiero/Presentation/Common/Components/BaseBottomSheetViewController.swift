//
//  BaseBottomSheetViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/14/26.
//

import UIKit

import SnapKit
import Then

class BaseBottomSheetViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = .kBlack.withAlphaComponent(0.75)
        $0.alpha = 0
    }
    
    let containerView = UIView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 15
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private var isInitialPositionSet = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        setGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isInitialPositionSet {
            let height = containerView.frame.height
            containerView.transform = CGAffineTransform(translationX: 0, y: height)
            isInitialPositionSet = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet()
    }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        view.addSubviews(dimmedView, containerView)
    }
    
    private func setLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSheet))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Animation
    
    private func showSheet() {
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    @objc
    func hideSheet() {
        let height = containerView.frame.height
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmedView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}
