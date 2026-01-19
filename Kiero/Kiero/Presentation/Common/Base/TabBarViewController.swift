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
        self.delegate = self
        
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
            
            self.viewControllers = [scheduleVC, notificationVC].map {
                let nav = UINavigationController(rootViewController: $0)
                nav.isNavigationBarHidden = true
                nav.delegate = self
                return nav
            }
            
            customTabBar.setTabItems(
                titles: ["스케줄 관리", "알림 피드"],
                icons: [.icCalendarLine, .icBell]
            )
        } else {
            let dailyJourneyVC = factory.makeDailyJourneyViewController()
            let coinMissionVC = factory.makeCoinMissionViewController()
            let wishWellVC = factory.makeWishWellViewController()
            
            self.viewControllers = [dailyJourneyVC, coinMissionVC, wishWellVC].map {
                let nav = UINavigationController(rootViewController: $0)
                nav.isNavigationBarHidden = true
                nav.delegate = self
                return nav
            }
            
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
            guard let self = self else { return }
            
            self.selectedIndex = index
            
            if let selectedVC = self.viewControllers?[index] {
                self.handleScrollToTop(for: selectedVC)
            }
            
            self.selectedIndex = index
        }
    }
    
    private func handleScrollToTop(for viewController: UIViewController) {
        let targetVC: UIViewController
        if let nav = viewController as? UINavigationController {
            targetVC = nav.viewControllers.first ?? viewController
        } else {
            targetVC = viewController
        }
        scrollToTop(viewController: targetVC)
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let targetVC: UIViewController
        if let nav = viewController as? UINavigationController {
            targetVC = nav.viewControllers.first ?? viewController
        } else {
            targetVC = viewController
        }
        
        scrollToTop(viewController: targetVC)
    }
    
    private func scrollToTop(viewController: UIViewController) {
        if let scrollableVC = viewController as? ScrollToTopAvailable {
            scrollableVC.scrollToTop()
            return
        }
        
        findScrollViewAndScrollToTop(in: viewController.view)
    }
    
    private func findScrollViewAndScrollToTop(in view: UIView) {
        for subview in view.subviews {
            if let tableView = subview as? UITableView {
                tableView.setContentOffset(.zero, animated: false)
                return
            } else if let scrollView = subview as? UIScrollView {
                scrollView.setContentOffset(.zero, animated: false)
                return
            }
            findScrollViewAndScrollToTop(in: subview)
        }
    }
}

protocol ScrollToTopAvailable {
    func scrollToTop()
}

extension TabBarViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let shouldHide = viewController.hidesBottomBarWhenPushed
        
        if shouldHide {
            self.customTabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.customTabBar.alpha = 0
        } else {
            self.customTabBar.transform = .identity
            self.customTabBar.alpha = 1
        }
    }
}

#Preview {
    TabBarViewController(factory: AppDIContainer.shared, isParent: true)
}
