//
//  View+.swift
//  Kiero
//
//  Created by 정윤아 on 3/4/26.
//

import SwiftUI

extension View {
    func showRewardBottomSheet(
        reward: Reward,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        let detailData = DetailModel(
            title: reward.title,
            type: .reward(price: reward.cost)
        )

        let bottomSheet = DetailBottomSheet(data: detailData)
        bottomSheet.onEditTap = onEdit
        bottomSheet.onDeleteTap = onDelete
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            let topVC = rootVC.presentedViewController ?? rootVC
            topVC.present(bottomSheet, animated: false)
        }
    }
}
