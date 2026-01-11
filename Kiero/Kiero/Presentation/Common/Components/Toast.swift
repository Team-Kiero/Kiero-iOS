//
//  Toast.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/11/26.
//

import UIKit

import SnapKit
import Then

final class Toast {
        
    static func show(message: String) {
        let windowScene: UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        guard let window: UIWindow = windowScene?.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        let toastView: ToastView = ToastView()
        
        toastView.configure(message: message)
        
        window.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.bottom.equalTo(window.safeAreaLayoutGuide).inset(31)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        self.animate(view: toastView)
    }
        
    private static func animate(view: UIView) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                view.alpha = 1.0
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 2.0,
                    options: .curveEaseOut,
                    animations: {
                        view.alpha = 0.0
                    },
                    completion: { _ in
                        view.removeFromSuperview()
                    }
                )
            }
        )
    }
}

private final class ToastView: UIView {
    
    // MARK: - UI Components
    
    private let messageLabel: UILabel = UILabel().then {
        $0.textColor = .schedule1
        $0.textAlignment = .center
        $0.font = .body4_12_R
        $0.numberOfLines = 1
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setStyle()
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        self.backgroundColor = .gray900
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.alpha = 0.0
    }
    
    private func setUI() {
        self.addSubview(self.messageLabel)
    }
    
    private func setLayout() {
        self.messageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(49)
        }
    }
        
    func configure(message: String) {
        self.messageLabel.text = message
    }
}
