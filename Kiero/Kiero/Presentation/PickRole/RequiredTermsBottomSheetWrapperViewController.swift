//
//  RequiredTermsBottomSheetWrapperViewController.swift
//  Kiero
//
//  Created by 안치욱 on 6/2/26.
//

import SwiftUI
import UIKit

final class RequiredTermsBottomSheetWrapperViewController: UIViewController {
    
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
        let bottomSafeArea = view.safeAreaInsets.bottom
        
        let hostingController = UIHostingController(
            rootView: ZStack(alignment: .bottom) {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                RequiredTermsBottomSheetView(
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
                
                Color.kBlack
                    .frame(height: bottomSafeArea)
            }
            .ignoresSafeArea(edges: .bottom)
        )
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = .clear
        hostingController.didMove(toParent: self)
    }
    
    private func openURL(_ urlString: String?) {
        guard let urlString,
              let url = URL(string: urlString)
        else { return }
        
        UIApplication.shared.open(url)
    }
}
