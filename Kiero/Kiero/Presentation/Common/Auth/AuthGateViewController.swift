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

    // MARK: - Properties

    private let viewModel: AuthGateViewModel
    private var cancellables = Set<AnyCancellable>()
    private var pendingWork: DispatchWorkItem?
    
    private var dimPanelBottomConstraint: Constraint?
    private var pickRoleBottomConstraint: Constraint?


    private var overlayPrepared = false

    private enum IntroTiming {
        static let splashHold: TimeInterval = 2.3
        static let dimDuration: TimeInterval = 0.25
        static let pickRoleDuration: TimeInterval = 0.35
        static let pickRoleDelayAfterDimStart: TimeInterval = 0.08

        static let dimPanelHeight: CGFloat = 520
        static let pickRoleHiddenOffset: CGFloat = 1000
    }

    // MARK: - UI Components

    private let splashView = SplashView()

    private let dimPanelView = GradientDimView().then {
        $0.isUserInteractionEnabled = true
    }

    private let pickRoleView = PickRoleView()

    // MARK: - Init

    init(viewModel: AuthGateViewModel = AuthGateViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        bind()
        viewModel.decideRoute()
    }

    // MARK: - Setup Methods

    private func setUI() {
        view.addSubview(splashView)
        splashView.snp.makeConstraints { $0.edges.equalToSuperview() }
        splashView.start()
    }

    // MARK: - Bind

    private func bind() {
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }

                if route == .parentOnboarding {
                    self.transition(after: 2.0, to: route)
                } else {
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
                self?.showPickRoleOverlaySequence()
            }

        case .parentOnboarding:
            let vc = AppDIContainer.shared.makeParentOnboardingViewController()
            changeRoot(UINavigationController(rootViewController: vc))

        case .parentTab:
            changeRoot(TabBarViewController(factory: AppDIContainer.shared, isParent: true))

        case .childTab:
            changeRoot(TabBarViewController(factory: AppDIContainer.shared, isParent: false))
        }
    }

    private func prepareOverlaysIfNeeded() {
        guard !overlayPrepared else { return }
        overlayPrepared = true
        
        view.addSubviews(dimPanelView, pickRoleView)

        dimPanelView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(IntroTiming.dimPanelHeight)
            self.dimPanelBottomConstraint = $0.bottom
                .equalToSuperview()
                .offset(IntroTiming.dimPanelHeight)
                .constraint
        }

        pickRoleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            self.pickRoleBottomConstraint = $0.bottom
                .equalTo(view.safeAreaLayoutGuide)
                .offset(IntroTiming.pickRoleHiddenOffset)
                .constraint
        }

        pickRoleView.onTapStart = { [weak self] role in
            self?.goLoginFlow(for: role)
        }
    }

    private func showPickRoleOverlaySequence() {
        view.layoutIfNeeded()

        UIView.animate(withDuration: IntroTiming.dimDuration,
                       delay: 0,
                       options: [.curveEaseOut]) {
            self.dimPanelView.alpha = 1
            self.dimPanelBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }

        UIView.animate(withDuration: IntroTiming.pickRoleDuration,
                       delay: IntroTiming.pickRoleDelayAfterDimStart,
                       options: [.curveEaseOut]) {
            self.pickRoleBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Navigation

    private func goLoginFlow(for role: LoginUser) {
        let vc: UIViewController
        switch role {
        case .parent:
            let vm = ParentLoginViewModel()
            vc = ParentLoginViewController(viewModel: vm, diContainer: AppDIContainer.shared)
            
        case .child:
            vc = ChildrenLoginViewController(viewModel: ChildrenLoginViewModel(), diContainer: AppDIContainer.shared)
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func changeRoot(_ vc: UIViewController) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(vc)
        }
    }
}
