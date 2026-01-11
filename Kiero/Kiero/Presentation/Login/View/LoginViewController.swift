//
//  LoginViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/12/26.
//


import UIKit
import Combine

final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    private let kakaoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("카카오로 로그인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.backgroundColor = .systemYellow
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "대기중"
        return label
    }()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUI()
        bind()
    }

    private func setUI() {
        view.addSubview(kakaoButton)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            kakaoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kakaoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            kakaoButton.widthAnchor.constraint(equalToConstant: 220),
            kakaoButton.heightAnchor.constraint(equalToConstant: 52),

            statusLabel.topAnchor.constraint(equalTo: kakaoButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        kakaoButton.addTarget(self, action: #selector(didTapKakao), for: .touchUpInside)
    }

    private func bind() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }

                switch state {
                case .idle:
                    self.statusLabel.text = "대기중"
                    self.kakaoButton.isEnabled = true
                    self.kakaoButton.alpha = 1

                case .loading:
                    self.statusLabel.text = "로그인 요청 중..."
                    self.kakaoButton.isEnabled = false
                    self.kakaoButton.alpha = 0.6

                case .failure(let message):
                    self.statusLabel.text = "❌ 로그인 실패\n\(message)"
                    self.kakaoButton.isEnabled = true
                    self.kakaoButton.alpha = 1
                }
            }
            .store(in: &cancellables)

        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                switch route {
                case .home:
                    self?.goToHome()
                }
            }
            .store(in: &cancellables)
    }

    @objc private func didTapKakao() {
        viewModel.kakaoButtonTapped.send(())
    }

    private func goToHome() {
        let homeVC = UIViewController()
        homeVC.view.backgroundColor = .systemGreen
        homeVC.title = "Home"
        
        self.present(homeVC, animated: true)
    }
}
