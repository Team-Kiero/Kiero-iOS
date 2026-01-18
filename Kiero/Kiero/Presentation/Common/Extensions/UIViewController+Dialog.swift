//
//  UIViewController+Dialog.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//

import UIKit

import SnapKit
import Then

extension UIViewController {
    func showLogoutDialog(oncConfirm: @escaping () -> Void) {
        let dimmedView = UIView().then {
            $0.backgroundColor = UIColor.kBlack.withAlphaComponent(0.75)
            $0.alpha = 1
        }
        
        let dialogBox = DialogBox().then {
            $0.configure(state: .logout)
            $0.alpha = 1
        }
        
        view.addSubviews(dimmedView, dialogBox)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dialogBox.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        dialogBox.onTapCancel = {
            self.dismissDialog(dimmedView, dialogBox)
        }
        
        dialogBox.onTapConfirm = { [weak self] in
            self?.dismissDialog(dimmedView, dialogBox)
            self?.performLogout()
        }
    }
    
    func performLogout() {
        // TODO: 로그아웃시 역할 선택 화면으로 이동
        print("로그아웃 눌림")
    }
    
    func dismissDialog(_ dimmed: UIView, _ dialog: UIView) {
        dimmed.removeFromSuperview()
        dialog.removeFromSuperview()
    }
}
