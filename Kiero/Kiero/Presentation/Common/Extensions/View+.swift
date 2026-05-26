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
        
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .first(where: {$0.activationState == .foregroundActive}),
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController {
            let topVC = rootVC.presentedViewController ?? rootVC
            topVC.present(bottomSheet, animated: false)
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
