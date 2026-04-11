//
//  TabBarViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/9/26.
//

import Combine
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
    
    private let feedService: FeedServiceType = FeedService()
    private var cancellables = Set<AnyCancellable>()
    private var hasUnreadNotification = false
    private var globalSseStarted = false
    private var isShowingNotificationFeed = false
    
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
    
    private lazy var chromeDimView = UIView().then {
        $0.backgroundColor = UIColor.kBlack
        $0.alpha = 0
        $0.isUserInteractionEnabled = false
    }
    
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
        setChromeDimViewUI()
        bindNotifications()
        bindUnreadState()
        bindSSEEvents()
        
        if isParent {
            fetchInitialUnreadStatus()
            startGlobalFeedSSEIfNeeded()
        }
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
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
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
                titles: ["오늘 현황", "일정", "미션", "보상", "마이페이지"],
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
    
    func setChromeDimViewUI() {
        view.addSubview(chromeDimView)
        
        chromeDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.bringToFront(
            customNavigationBar,
            customTabBar,
            chromeDimView
        )
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
        
        NotificationBadgeCenter.shared.setUnread(false)
        
        guard let nav = selectedViewController as? UINavigationController else { return }
        nav.pushViewController(notificationVC, animated: true)
    }
    
    func navigationBarStyle(for index: Int) -> TabNavigationBarStyle? {
        if isParent {
            switch index {
            case 0:
                return .init(title: nil, type: .main(title: nil), isNotificationActive: hasUnreadNotification)
            case 1:
                return .init(title: "일정", type: .main(title: "일정"), isNotificationActive: hasUnreadNotification)
            case 2:
                return .init(title: "미션", type: .main(title: "미션"), isNotificationActive: hasUnreadNotification)
            case 3:
                return .init(title: "보상", type: .main(title: "보상"), isNotificationActive: hasUnreadNotification)
            case 4:
                return .init(title: "마이페이지", type: .main(title: "마이페이지"), isNotificationActive: hasUnreadNotification)
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
            self.chromeDimView.alpha = isDimmed ? 0.75 : 0.0
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
        
        let isNotificationFeed = viewController is NotificationFeedViewController
        isShowingNotificationFeed = isNotificationFeed
        
        customTabBar.isHidden = shouldHideTabBar
        customTabBar.alpha = shouldHideTabBar ? 0 : 1
        customTabBar.isUserInteractionEnabled = !shouldHideTabBar
        
        customNavigationBar.isHidden = shouldHideNavigationBar
        customNavigationBar.alpha = shouldHideNavigationBar ? 0 : 1
        customNavigationBar.isUserInteractionEnabled = !shouldHideNavigationBar
        
        if !shouldHideNavigationBar {
            updateNavigationBar()
        }
        
        view.bringToFront(
            customNavigationBar,
            customTabBar,
            chromeDimView
        )
    }
}

private extension TabBarViewController {
    func bindUnreadState() {
        NotificationBadgeCenter.shared.hasUnreadSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasUnread in
                guard let self else { return }
                self.hasUnreadNotification = hasUnread
                self.customNavigationBar.isNotificationActive = hasUnread
            }
            .store(in: &cancellables)
    }
    
    func fetchInitialUnreadStatus() {
        feedService.fetchUnreadFeed()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ unread fetch finished")
                case .failure(let error):
                    print("❌ unread fetch failed:", String(reflecting: error))
                    debugPrint(error)
                }
            } receiveValue: { status in
                print("✅ unread status:", status.hasUnread)
                NotificationBadgeCenter.shared.setUnread(status.hasUnread)
            }
            .store(in: &cancellables)
    }
    
    func startGlobalFeedSSEIfNeeded() {
        guard !globalSseStarted else { return }
        globalSseStarted = true
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let initialToken = try await TokenRefresher.shared.reissueSseAccessToken()
                
                await MainActor.run {
                    SseStreamManager.shared.startIfNeeded(initialToken: initialToken) { payload in
                        print("📡 raw SSE event:", payload.eventType)
                    }
                    print("✅ [TabBar] global SSE started")
                }
            } catch {
                print("❌ [TabBar] SSE start failed:", error)
                self.globalSseStarted = false
            }
        }
    }
    
    func bindSSEEvents() {
        NotificationCenter.default.publisher(for: .sseEventReceived)
            .compactMap { $0.userInfo?["payload"] as? SseEventPayload }
            .sink { [weak self] payload in
                guard let self else { return }
                print("📡 TabBar received SSE:", payload.eventType)
                
                guard payload.eventType == "FEED_ITEM_CREATED" else { return }
                
                NotificationCenter.default.post(
                    name: .feedItemCreated,
                    object: nil,
                    userInfo: ["payload": payload]
                )
                
                if !self.isShowingNotificationFeed {
                    NotificationBadgeCenter.shared.setUnread(true)
                }
            }
            .store(in: &cancellables)
    }
}
