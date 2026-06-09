//
//  RequiredTermsBottomSheetHostingViewController.swift
//  Kiero
//
//  Created by 안치욱 on 6/2/26.
//

import SwiftUI
import UIKit

final class RequiredTermsBottomSheetHostingViewController: UIViewController {
    
    private let serviceTermsURL: String?
    private let privacyPolicyURL: String?
    private let onConfirm: () -> Void
    
    init(
        serviceTermsURL: String?,
        privacyPolicyURL: String?,
        onConfirm: @escaping () -> Void
    ) {
        self.serviceTermsURL = serviceTermsURL
        self.privacyPolicyURL = privacyPolicyURL
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .clear
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(dimView)
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
        dimView.addGestureRecognizer(tapGesture)
        
        let hostingController = UIHostingController(
            rootView: RequiredTermsBottomSheetView(
                onTermsTap: { [weak self] in
                    self?.openURL(self?.serviceTermsURL)
                },
                onPrivacyTap: { [weak self] in
                    self?.openURL(self?.privacyPolicyURL)
                },
                onConfirm: { [weak self] in
                    self?.dismiss(animated: false) {
                        self?.onConfirm()
                    }
                }
            )
        )
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.backgroundColor = UIColor(resource: .kBlack)
        
        hostingController.view.layer.cornerRadius = 15
        hostingController.view.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        
        hostingController.view.layer.shadowColor = UIColor(resource: .gray800).cgColor
        hostingController.view.layer.shadowOffset = CGSize(width: 0, height: -1)
        hostingController.view.layer.shadowRadius = 4
        hostingController.view.layer.shadowOpacity = 0.5
        
        hostingController.view.layer.masksToBounds = false
        hostingController.view.clipsToBounds = false
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    @objc
    private func dimViewTapped() {
        dismiss(animated: false)
    }
    
    private func openURL(_ urlString: String?) {
        guard let urlString,
              let url = URL(string: urlString)
        else { return }
        
        UIApplication.shared.open(url)
    }
}
