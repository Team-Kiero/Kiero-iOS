//
//  NavigationBar.swift
//  Kiero
//
//  Created by 신혜연 on 1/10/26.
//

import UIKit

import SnapKit
import Then

enum NavigationBarType {
    case back(title: String)         // <
    case closeDone(title: String)    // x v
    case close(title: String)        // x
    case main(title: String? = nil)
    case titleClose(title: String)   //   x
}

final class NavigationBar: UIView {
    
    // MARK: - Properties
    
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    
    var isRightButtonEnabled: Bool = true {
        didSet {
            rightButton.isEnabled = isRightButtonEnabled
            rightButton.alpha = isRightButtonEnabled ? 1.0 : 0.5
        }
    }
    
    private var currentType: NavigationBarType = .main()

    var isNotificationActive: Bool = false {
        didSet {
            guard case .main = currentType else { return }
            let icon = isNotificationActive ? UIImage(resource: .icAlarmPin) : UIImage(resource: .icAlarm)
            rightButton.setImage(icon, for: .normal)
        }
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    let leftButton = UIButton().then {
        $0.tintColor = .white
    }
    
    let rightButton = UIButton().then {
        $0.tintColor = .white
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgLogo)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    
    init(type: NavigationBarType, backgroundColor: UIColor = .clear) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        
        setUI()
        setLayout()
        configure(with: type)
        setAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        addSubviews(leftButton, titleLabel, rightButton, logoImageView)
    }
    
    private func setLayout() {
        leftButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(23)
            $0.width.equalTo(108)
        }
    }
    
    private func configure(with type: NavigationBarType) {
        currentType = type
        titleLabel.snp.remakeConstraints { $0.center.equalToSuperview() }
        titleLabel.isHidden = false
        logoImageView.isHidden = true
        leftButton.isHidden = false
        rightButton.isHidden = false
        
        rightButton.snp.updateConstraints {
            $0.trailing.equalToSuperview().inset(8)
        }
        
        switch type {
        case .back(let title):
            titleLabel.setTypo(.head2_20_B, text: title)
            leftButton.setImage(UIImage(resource: .icLeft), for: .normal)
            rightButton.isHidden = true
            
        case .closeDone(let title):
            titleLabel.setTypo(.head2_20_B, text: title)
            leftButton.setImage(UIImage(resource: .icCloseLight), for: .normal)
            rightButton.setImage(UIImage(resource: .icDone), for: .normal)
            rightButton.isHidden = false
            
        case .close(let title):
            titleLabel.setTypo(.head2_20_B, text: title)
            leftButton.setImage(UIImage(resource: .icCloseLight), for: .normal)
            rightButton.isHidden = true
            
        case .main(let title):
            leftButton.isHidden = true
            
            rightButton.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(16)
            }
            
            if let title = title {
                titleLabel.setTypo(.head2_20_B, text: title)
                titleLabel.snp.remakeConstraints {
                    $0.leading.equalToSuperview().offset(16)
                    $0.centerY.equalToSuperview()
                }
                logoImageView.isHidden = true
            } else {
                logoImageView.isHidden = false
                titleLabel.isHidden = true
            }
            
            let alarmIcon = isNotificationActive ? UIImage(resource: .icAlarmPin) : UIImage(resource: .icAlarm)
            rightButton.setImage(alarmIcon, for: .normal)
            
        case .titleClose(let title):
            leftButton.isHidden = true
            rightButton.setImage(.icClose, for: .normal)
            titleLabel.setTypo(.head3_16_B, text: title)
            
            rightButton.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
            titleLabel.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(16)
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    private func setAction() {
        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)
    }
    
    func setTitle(_ title: String) {
        titleLabel.setTypo(.head2_20_B, text: title)
    }
    
    func updateTitle(_ title: String) {
        titleLabel.setTypo(.title3_16_SB, text: title)
    }
    
    @objc
    private func didTapLeft() { leftButtonAction?() }
    
    @objc
    private func didTapRight() { rightButtonAction?() }
}
