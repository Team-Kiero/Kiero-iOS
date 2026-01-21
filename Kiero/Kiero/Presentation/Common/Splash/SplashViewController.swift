//
//  SplashViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/17/26.
//

import UIKit

import SnapKit
import Then

class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgBackground)
        $0.contentMode = .scaleAspectFill
    }
    
    private let gradientView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .sub
        $0.setTypo(.body2_16_R, text: "아이의 하루가 모험이 되는 곳")
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgLogo)
        $0.contentMode = .scaleAspectFit
    }
    
    private let characterImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgGoblinKid)
        $0.contentMode = .scaleAspectFit
    }
    
    private let lightViews: [UIView] = (0..<3).map { _ in
        let container = UIView()
        
        let glowView = UIView().then {
            $0.frame = CGRect(x: -35, y: -35, width: 30, height: 30)
            let gradient = CAGradientLayer()
            gradient.type = .radial
            gradient.frame = $0.bounds
            
            let centerColor = UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
            let edgeColor = UIColor.clear.cgColor
            
            gradient.colors = [centerColor, edgeColor]
            gradient.locations = [0.0, 1.0]
            
            gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            
            $0.layer.addSublayer(gradient)
        }
        
        let lightPoint = UIImageView().then {
            $0.image = UIImage(resource: .imgLight)
            $0.contentMode = .scaleAspectFit
            $0.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            $0.alpha = 0.2
        }
        
        container.addSubviews(glowView, lightPoint)
        glowView.center = CGPoint(x: 15, y: 15)
        
        return container
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setGradient()
        startFloatingAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transitionToMain()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        view.addSubviews(
            backgroundImageView,
            gradientView,
            titleLabel, logoImageView,
            characterImageView
        )
        
        lightViews.forEach { view.addSubview($0) }
    }
    
    private func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-22)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(189)
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.width.equalTo(300)
            $0.height.equalTo(63)
        }
        
        characterImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(23)
            $0.size.equalTo(420)
        }
        
        let positions = [
            (x: 60, y: 522),
            (x: 327, y: 612),
            (x: 20, y: 685)
        ]
        
        for (index, light) in lightViews.enumerated() {
            light.snp.makeConstraints {
                $0.size.equalTo(30)
                $0.leading.equalToSuperview().offset(positions[index].x)
                $0.top.equalToSuperview().offset(positions[index].y)
            }
        }
    }
    
    private func setGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        let color = UIColor(red: 35/255, green: 36/255, blue: 40/255, alpha: 1.0).cgColor
        gradientLayer.colors = [color.copy(alpha: 0.25)!, color.copy(alpha: 0.8)!]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Animation
    
    private func startFloatingAnimation() {
        UIView.animate(withDuration: 1.2,
                       delay: 0,
                       options: [.autoreverse, .repeat, .curveEaseInOut],
                       animations: {
            self.lightViews.forEach {
                $0.transform = CGAffineTransform(translationX: 0, y: -20)
            }
        })
    }
    
    private func transitionToMain() {
        let authVC = AuthGateViewController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(authVC)
        }
    }
}

#Preview {
    SplashViewController()
}
