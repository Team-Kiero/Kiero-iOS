//
//  TabBarViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/9/26.
//

import UIKit

import SnapKit
import Then

protocol ScrollToTopAvailable {
    func scrollToTop()
}

protocol TabBarReselectRefreshable {
    func refreshOnTabReselect()
}

public final class TabBarViewController: UITabBarController {
    
    public override var selectedIndex: Int {
        didSet {
            updateCustomTabBarSelection()
        }
    }
    
    public override var selectedViewController: UIViewController? {
        didSet {
            updateCustomTabBarSelection()
        }
    }
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTabBarHidden(_:)),
            name: .hideTabBar,
            object: nil
        )
    }
    
    @objc
    private func handleTabBarHidden(_ notification: Notification) {
        guard let isHidden = notification.object as? Bool else { return }
        
        UIView.animate(withDuration: 0.3) {
            let height = self.customTabBar.frame.height
            self.customTabBar.transform = isHidden ? CGAffineTransform(translationX: 0, y: height) : .identity
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate = self
    }
    
    private func updateCustomTabBarSelection() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.customTabBar.updateSelection(self.selectedIndex)
        }
    }
    
    private func setStyle() {
        self.tabBar.isHidden = true
        view.backgroundColor = .kBlack
    }
    
    private func setViewControllers() {
        if isParent {
            let statusVC = factory.makeTodayStatusViewController()
            let scheduleVC = factory.makeScheduleViewController()
            let missionVC = factory.makeMissionViewController()
            
            let rewardVC = factory.makeRewardViewController()
            let myPageVC = factory.makeMyPageViewController()
            
            self.viewControllers = [statusVC, scheduleVC, missionVC, rewardVC, myPageVC].map {
                if $0 is RewardHostingController || $0 is MyPageHostingViewController {
                    return $0
                }
                
                let nav = UINavigationController(rootViewController: $0)
                nav.isNavigationBarHidden = true
                nav.delegate = self
                return nav
            }
            
            customTabBar.setTabItems(
                titles: ["오늘의 현황", "일정", "미션", "보상", "마이페이지"],
                icons: [.icMap, .icCalenderFill, .icMission, .icStar, .icProfile]
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
            
            let isReclick = (self.selectedIndex == index)
            self.selectedIndex = index
            
            if let selectedVC = self.viewControllers?[index] {
                let targetVC = (selectedVC as? UINavigationController)?.viewControllers.first ?? selectedVC
                
                if isReclick {
                    if let scheduleVC = targetVC as? ScheduleViewController {
                        scheduleVC.viewModel?.currentReferenceDate.send(Date())
                    }
                    self.refreshOnReselect(targetVC)
                    self.scrollToTop(viewController: targetVC)
                }
            }
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
        if tabBarController.selectedViewController === viewController {
            (targetVC as? TabBarReselectRefreshable)?.refreshOnTabReselect()
        }
    }
    
    private func scrollToTop(viewController: UIViewController) {
        if let scrollableVC = viewController as? ScrollToTopAvailable {
            scrollableVC.scrollToTop()
            return
        }
        
        findScrollViewAndScrollToTop(in: viewController.view)
    }
    
    private func refreshOnReselect(_ viewController: UIViewController) {
        let target = (viewController as? UINavigationController)?.viewControllers.first ?? viewController
        
        if let refreshable = target as? TabBarReselectRefreshable {
            refreshable.refreshOnTabReselect()
            return
        }
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
