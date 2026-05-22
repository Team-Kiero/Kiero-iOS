//
//  PickRoleViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

//import Combine
//import UIKit
//
//import SnapKit
//import Then
//
//final class PickRoleViewController: BaseViewController<PickRoleViewModel> {
//    
//    private let parentTapSubject = PassthroughSubject<Void, Never>()
//    private let childTapSubject = PassthroughSubject<Void, Never>()
//    
//    private let logoImageView = UIImageView().then {
//        $0.image = .imgLogo
//        $0.tintColor = .white
//        $0.contentMode = .scaleAspectFit
//    }
//    
//    private let descriptionLabel = UILabel().then {
//        $0.textColor = .schedule1
//        $0.textAlignment = .center
//    }
//    
//    private let parentButton = RolePickButton(type: .parent)
//    
//    private let childButton = RolePickButton(type: .child)
//    
//    override func setStyle() {
//        descriptionLabel.setTypo(.body2_16_R, text: "아이의 하루가 모험이 되는 곳")
//    }
//    
//    override func setUI() {
//        view.addSubviews(
//            logoImageView,
//            descriptionLabel,
//            parentButton,
//            childButton
//        )
//    }
//    
//    override func setLayout() {
//        logoImageView.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
//            $0.width.equalTo(300)
//            $0.height.equalTo(63)
//        }
//        
//        descriptionLabel.snp.makeConstraints {
//            $0.centerX.equalToSuperview().offset(-22)
//            $0.top.equalTo(view.safeAreaLayoutGuide).offset(189)
//        }
//        
//        childButton.snp.makeConstraints {
//            $0.horizontalEdges.equalToSuperview().inset(16)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-78)
//        }
//        
//        parentButton.snp.makeConstraints {
//            $0.horizontalEdges.equalToSuperview().inset(16)
//            $0.bottom.equalTo(childButton.snp.top).offset(-25)
//        }
//    }
//    
//    override func addTarget() {
//        parentButton.onTap = { [weak self] in
//            self?.parentTapSubject.send(())
//        }
//        
//        childButton.onTap = { [weak self] in
//            self?.childTapSubject.send(())
//        }
//    }
//    
//    override func bind(viewModel: PickRoleViewModel) {
//        super.bind(viewModel: viewModel)
//        
//        let input = PickRoleViewModel.Input(
//            parentTapped: parentTapSubject.eraseToAnyPublisher(),
//            childTapped: childTapSubject.eraseToAnyPublisher()
//        )
//        
//        let output = viewModel.transform(input: input)
//        
//        output.route
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] route in
//                self?.handle(route)
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func handle(_ route: PickRoleRoute) {
//        switch route {
//        case .parentLogin:
//            //navigateToParentLogin()
//        case .childLogin:
//            //navigateToChildrenLogin()
//        }
//    }
//    
//    private func navigateToParentLogin() {
//        let vc = diContainer.makeParentLoginViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    private func navigateToChildrenLogin() {
//        let vc = diContainer.makeChildrenLoginViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
