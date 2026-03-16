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

struct TabNavigationBarStyle {
    let title: String?
    let type: NavigationBarType
    let isNotificationActive: Bool
}

public final class TabBarViewController: UITabBarController {
    
    public override var selectedIndex: Int {
        didSet {
            updateCustomTabBarSelection()
            updateNavigationBar()
        }
    }
    
    public override var selectedViewController: UIViewController? {
        didSet {
            updateCustomTabBarSelection()
            updateNavigationBar()
        }
    }
    
    private let factory: ViewControllerFactory
    private let isParent: Bool
    
    private lazy var customNavigationBar = NavigationBar(type: .main()).then {
        $0.rightButtonAction = { [weak self] in
            self?.handleNavigationBarRightTap()
        }
        $0.leftButtonAction = { [weak self] in
            self?.handleNavigationBarLeftTap()
        }
    }
    
    private lazy var customTabBar = TabBarView(
        cornerRadius: isParent ? 24 : 0,
        isParent: isParent
    )
    
    private var customTabBarBottomConstraint: Constraint?
    
    public init(factory: ViewControllerFactory, isParent: Bool) {
        self.factory = factory
        self.isParent = isParent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        setStyle()
        setViewControllers()
        setCustomNavigationBarUI()
        setCustomTabBarUI()
        bindNotifications()
        updateNavigationBar()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate = self
    }
}

// MARK: - Setup

private extension TabBarViewController {

    func setStyle() {
        tabBar.isHidden = true
        view.backgroundColor = .kBlack

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.backgroundEffect = nil

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = .clear
        tabBar.barTintColor = .clear
        tabBar.isTranslucent = true
    }
    
    func setViewControllers() {
        if isParent {
            let statusVC = factory.makeTodayStatusViewController()
            let scheduleVC = factory.makeScheduleViewController()
            let missionVC = factory.makeMissionViewController()
            let rewardVC = factory.makeRewardViewController()
            let myPageVC = factory.makeMyPageViewController()
            
            viewControllers = [statusVC, scheduleVC, missionVC, rewardVC, myPageVC].map {
                let nav = UINavigationController(rootViewController: $0)
                nav.isNavigationBarHidden = true
                nav.delegate = self
                nav.view.backgroundColor = .kBlack
                $0.view.backgroundColor = .kBlack
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
            
            viewControllers = [dailyJourneyVC, coinMissionVC, wishWellVC].map {
                let nav = UINavigationController(rootViewController: $0)
                nav.isNavigationBarHidden = true
                nav.delegate = self
                nav.view.backgroundColor = .kBlack
                $0.view.backgroundColor = .kBlack
                return nav
            }
            
            customTabBar.setTabItems(
                titles: ["오늘의 여정", "금화 미션", "소원의 우물"],
                icons: [.icMap, .icCoin, .icStar]
            )
        }
        
        customTabBar.updateSelection(0)
    }
    
    func setCustomNavigationBarUI() {
        view.addSubview(customNavigationBar)
         
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(13)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(45)
        }
        customNavigationBar.isHidden = !isParent
    }
    
    func setCustomTabBarUI() {
        view.addSubview(customTabBar)
        view.clipsToBounds = false

        customTabBar.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }

        view.bringSubviewToFront(customNavigationBar)
        view.bringSubviewToFront(customTabBar)

        customTabBar.onTabSelected = { [weak self] index in
            guard let self else { return }

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
    
    func bindNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTabBarHidden(_:)),
            name: .hideTabBar,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChromeAlpha(_:)),
            name: .dimNavigationBar,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNavigationBarHidden(_:)),
            name: .hideNavigationBar,
            object: nil
        )
    }
    
    func updateCustomTabBarSelection() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.customTabBar.updateSelection(self.selectedIndex)
        }
    }
}

// MARK: - Navigation Bar

private extension TabBarViewController {
    
    func updateNavigationBar() {
        guard let style = navigationBarStyle(for: selectedIndex) else {
            customNavigationBar.isHidden = true
            return
        }
        
        customNavigationBar.isHidden = false
        
        var resolvedType = style.type
        
        if let nav = selectedViewController as? UINavigationController,
           nav.viewControllers.count > 1 {
            resolvedType = .back(title: style.title ?? "")
        }
        
        customNavigationBar.apply(type: resolvedType)
        customNavigationBar.isNotificationActive = style.isNotificationActive
    }
    
    func handleNavigationBarLeftTap() {
        if let nav = selectedViewController as? UINavigationController,
           nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        }
    }
    
    func handleNavigationBarRightTap() {
        let notificationVC = factory.makeNotificationFeedViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        
        guard let nav = selectedViewController as? UINavigationController else { return }
        nav.pushViewController(notificationVC, animated: true)
    }
    
    func navigationBarStyle(for index: Int) -> TabNavigationBarStyle? {
        if isParent {
            switch index {
            case 0:
                return .init(title: nil, type: .main(title: nil), isNotificationActive: false)
            case 1:
                return .init(title: "일정", type: .main(title: "일정"), isNotificationActive: false)
            case 2:
                return .init(title: "미션", type: .main(title: "미션"), isNotificationActive: false)
            case 3:
                return .init(title: "보상", type: .main(title: "보상"), isNotificationActive: false)
            case 4:
                return .init(title: "마이페이지", type: .main(title: "마이페이지"), isNotificationActive: false)
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: - Notification Handlers

private extension TabBarViewController {
    @objc
    func handleTabBarHidden(_ notification: Notification) {
        guard let isHidden = notification.object as? Bool else { return }
        
        UIView.animate(withDuration: 0.25) {
            self.customTabBar.alpha = isHidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func handleChromeAlpha(_ notification: Notification) {
        guard let isDimmed = notification.object as? Bool else { return }

        UIView.animate(withDuration: 0.25) {
            self.customNavigationBar.alpha = isDimmed ? 0.25 : 1.0
            self.customTabBar.alpha = isDimmed ? 0 : 1.0
        }
    }
    
    @objc
    private func handleNavigationBarHidden(_ notification: Notification) {
        guard let isHidden = notification.object as? Bool else { return }
        
        UIView.animate(withDuration: 0.25) {
            self.customNavigationBar.alpha = isHidden ? 0 : 1
            self.customTabBar.alpha = isHidden ? 0 : 1
            self.customNavigationBar.isUserInteractionEnabled = !isHidden
        }
    }
}

// MARK: - UITabBarControllerDelegate

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

// MARK: - UINavigationControllerDelegate

extension TabBarViewController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let shouldHideTabBar = viewController.hidesBottomBarWhenPushed
        let shouldHideNavigationBar = shouldHideTabBar || !isParent

        customTabBar.isHidden = shouldHideTabBar
        customTabBar.alpha = shouldHideTabBar ? 0 : 1
        customTabBar.isUserInteractionEnabled = !shouldHideTabBar

        customNavigationBar.isHidden = shouldHideNavigationBar
        customNavigationBar.alpha = shouldHideNavigationBar ? 0 : 1
        customNavigationBar.isUserInteractionEnabled = !shouldHideNavigationBar

        if !shouldHideNavigationBar {
            updateNavigationBar()
        }

        view.bringSubviewToFront(customNavigationBar)
        view.bringSubviewToFront(customTabBar)
    }
}
