//
//  TabBarViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/9/26.
//

import UIKit

import SnapKit
import Then

public final class TabBarViewController: UITabBarController {
    
    private let factory: ViewControllerFactory
    private let isParent: Bool
    
    private lazy var customTabBar = TabBarView(cornerRadius: isParent ? 24 : 0, isParent: isParent)

    public init(factory: ViewControllerFactory, isParent: Bool) {
        self.factory = factory
        self.isParent = isParent
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyle()
        setViewControllers()
        setCustomTabBarUI()
    }
    
    private func setStyle() {
        self.tabBar.isHidden = true
        view.backgroundColor = .kBlack
    }
    
    private func setViewControllers() {
        if isParent {
            let scheduleVC = factory.makeScheduleViewController()
            let notificationVC = factory.makeNotificationFeedViewController()
            
            self.viewControllers = [scheduleVC, notificationVC].map { UINavigationController(rootViewController: $0) }
            
            customTabBar.setTabItems(
                titles: ["스케줄 관리", "알림 피드"],
                icons: [.icCalendarLine, .icBell]
            )
        } else {
            let dailyJourneyVC = factory.makeDailyJourneyViewController()
            let coinMissionVC = factory.makeCoinMissionViewController()
            let wishWellVC = factory.makeWishWellViewController()
            
            self.viewControllers = [dailyJourneyVC, coinMissionVC, wishWellVC].map { UINavigationController(rootViewController: $0) }
            
            customTabBar.setTabItems(
                titles: ["오늘의 여정", "금화 미션", "소원의 우물"],
                icons: [.icMap, .icCoin, .icStar]
            )
        }
        customTabBar.updateSelection(0)
    }

    private func setCustomTabBarUI() {
        view.addSubview(customTabBar)
        view.clipsToBounds = false
        
        customTabBar.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        customTabBar.onTabSelected = { [weak self] index in
            self?.selectedIndex = index
        }
    }
}

#Preview {
    TabBarViewController(factory: AppDIContainer.shared, isParent: true)
}
