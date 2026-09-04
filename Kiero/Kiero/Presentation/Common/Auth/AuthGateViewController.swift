//
//  AuthGateViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class AuthGateViewController: UIViewController {

    private let viewModel: AuthGateViewModel
    private var cancellables = Set<AnyCancellable>()
    private var pendingWork: DispatchWorkItem?
    
    private var dimPanelBottomConstraint: Constraint?

    private var overlayPrepared = false
    
    private var currentRole: LoginUser {
#if KIERO_PARENT
        return .parent
#elseif KIERO_CHILD
        return .child
#else
        fatalError("KIERO_PARENT 또는 KIERO_CHILD 플래그가 정의되어 있지 않습니다.")
#endif
    }

    private enum IntroTiming {
        static let splashHold: TimeInterval = 2.3
        static let dimDuration: TimeInterval = 0.25
        static let dimPanelHeight: CGFloat = 500
        static let dimFadeStartY: CGFloat = 30
        static let dimSolidStartY: CGFloat = 400
    }
    
    private let splashView = SplashView()

    private let dimPanelView = GradientDimView().then {
        $0.isUserInteractionEnabled = true
        $0.fadeStartY = IntroTiming.dimFadeStartY
        $0.solidStartY = IntroTiming.dimSolidStartY
    }
    
    private let startButton = CTAButton(enabledStyle: .main, disabledStyle: .gray900, size: .h49).then {
        $0.configure(title: "시작하기")
    }

    init(viewModel: AuthGateViewModel = AuthGateViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        bind()
        viewModel.decideRoute()
    }

    private func setUI() {
        view.addSubview(splashView)
        splashView.snp.makeConstraints { $0.edges.equalToSuperview() }
        splashView.start()
    }

    private func bind() {
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }

                switch route {
                case .parentOnboarding:
                    self.transition(after: 2.0, to: route)

                default:
                    self.transition(after: 0.0, to: route)
                }
            }
            .store(in: &cancellables)
    }

    private func transition(after seconds: TimeInterval, to route: AuthGateRoute) {
        pendingWork?.cancel()

        let work = DispatchWorkItem { [weak self] in
            self?.handle(by: route)
        }

        pendingWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }

    private func handle(by route: AuthGateRoute) {
        switch route {
        case .pickRole:
            prepareOverlaysIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + IntroTiming.splashHold) { [weak self] in
                self?.showStartButtonSequence()
            }
            
        case .parentRequiredTerms(let terms):
#if KIERO_PARENT
            guard let nav = navigationController,
                  let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            
            let coordinator = ParentCoordinator(navigationController: nav, diContainer: AppDIContainer.shared)
            coordinator.onRequestRootChange = { [weak sceneDelegate] vc in
                sceneDelegate?.changeRootViewController(vc)
            }
            sceneDelegate.parentCoordinator = coordinator
            coordinator.showParentLogin(pendingRequiredTerms: terms)
#endif
            
        case .parentOnboarding:
#if KIERO_PARENT
            guard let nav = navigationController,
                  let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            
            let coordinator = ParentCoordinator(navigationController: nav, diContainer: AppDIContainer.shared)
            coordinator.onRequestRootChange = { [weak sceneDelegate] vc in
                sceneDelegate?.changeRootViewController(vc)
            }
            sceneDelegate.parentCoordinator = coordinator
            coordinator.showParentOnboardingDirectly()
#endif
            
        case .parentTab:
            changeRoot(TabBarViewController(factory: AppDIContainer.shared, isParent: true))

        case .childTab:
            changeRoot(TabBarViewController(factory: AppDIContainer.shared, isParent: false))
        }
    }

    private func prepareOverlaysIfNeeded() {
        guard !overlayPrepared else { return }
        overlayPrepared = true
        
        view.addSubviews(dimPanelView)
        dimPanelView.addSubview(startButton)

        dimPanelView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(IntroTiming.dimPanelHeight)
            self.dimPanelBottomConstraint = $0.bottom
                .equalToSuperview()
                .offset(IntroTiming.dimPanelHeight)
                .constraint
        }

        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(dimPanelView.safeAreaLayoutGuide).inset(17)
            $0.height.equalTo(49)
        }

        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
    }

    private func showStartButtonSequence() {
        view.layoutIfNeeded()

        UIView.animate(
            withDuration: IntroTiming.dimDuration,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.dimPanelView.alpha = 1
            self.dimPanelBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapStart() {
        goLoginFlow(for: currentRole)
    }

    private func goLoginFlow(for role: LoginUser) {
        switch role {
        case .parent:
#if KIERO_PARENT
            guard let nav = navigationController,
                  let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            
            let coordinator = ParentCoordinator(navigationController: nav, diContainer: AppDIContainer.shared)
            coordinator.onRequestRootChange = { [weak sceneDelegate] vc in
                sceneDelegate?.changeRootViewController(vc)
            }
            sceneDelegate.parentCoordinator = coordinator
            coordinator.start()
#endif
            
        case .child:
#if KIERO_CHILD
            guard let nav = navigationController,
                  let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }

            let coordinator = ChildCoordinator(navigationController: nav, diContainer: AppDIContainer.shared)
            coordinator.onRequestRootChange = { [weak sceneDelegate] vc in
                sceneDelegate?.changeRootViewController(vc)
            }
            sceneDelegate.childCoordinator = coordinator
            coordinator.start()
#endif
        }
    }

    private func changeRoot(_ vc: UIViewController) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(vc)
        }
    }
}
