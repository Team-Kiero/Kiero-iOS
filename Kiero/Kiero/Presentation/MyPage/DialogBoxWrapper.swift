//
//  DialogBoxWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import SwiftUI
import UIKit

struct DialogBoxWrapper: UIViewRepresentable {
    var state: DialogBox.State
    @Binding var isPresented: Bool
    var onConfirm: (() -> Void)?
    
    func makeUIView(context: Context) -> DialogBox {
        let view = DialogBox()
        
        view.onTapClose = {
            isPresented = false
        }
        
        view.onTapCancel = {
            isPresented = false
        }
        
        view.onTapConfirm = {
            onConfirm?()
            isPresented = false
        }
        
        return view
    }
    
    func updateUIView(_ uiView: DialogBox, context: Context) {
        uiView.configure(state: state)
    }
}
