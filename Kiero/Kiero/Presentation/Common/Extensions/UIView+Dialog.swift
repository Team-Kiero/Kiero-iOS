//
//  UIView+Dialog.swift
//  Kiero
//
//  Created by 정윤아 on 1/13/26.
//

import UIKit

import SnapKit
import Then

extension UIView {
    func showDialog(state: DialogBox.State, onConfirm: @escaping () -> Void) {
        let dimView = UIView().then {
            $0.backgroundColor = .kBlack.withAlphaComponent(0.75)
            $0.alpha = 0
        }
        let dialogBox = DialogBox()
        dialogBox.configure(state: state)
        
        self.addSubview(dimView)
        dimView.addSubview(dialogBox)   
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dialogBox.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        UIView.animate(withDuration: 0.2) { dimView.alpha = 1 }
        
        let dismiss = {
            UIView.animate(withDuration: 0.2, animations: { dimView.alpha = 0 }) { _ in
                dimView.removeFromSuperview()
            }
        }
        
        dialogBox.onTapClose = dismiss
        dialogBox.onTapCancel = dismiss
        dialogBox.onTapConfirm = {
            onConfirm()
            dismiss()
        }
    }
    
    func showConfirm(state: ConfirmBox.State, onConfirm: (() -> Void)? = nil) {
        let dimView = UIView().then {
            $0.backgroundColor = .black.withAlphaComponent(0.75)
            $0.alpha = 0
        }
        let confirmBox = ConfirmBox()
        confirmBox.configure(state: state)
        
        self.addSubview(dimView)
        dimView.addSubview(confirmBox)
        
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        confirmBox.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        UIView.animate(withDuration: 0.2) { dimView.alpha = 1 }
        
        confirmBox.onTapButton = {
            UIView.animate(withDuration: 0.2, animations: { dimView.alpha = 0 }) { _ in
                dimView.removeFromSuperview()
                onConfirm?()
            }
        }
    }
}
