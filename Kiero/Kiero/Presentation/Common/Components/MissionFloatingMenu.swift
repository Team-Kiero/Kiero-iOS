//
//  MissionFloatingMenu.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class MissionFloatingMenuView: UIView {
    
    // MARK: - Properties
    
    var onMenuSelected: ((Int) -> Void)?
    
    // MARK: - UI Components
    
    private let dimView = UIView().then {
        $0.backgroundColor = .kBlack.withAlphaComponent(0.75)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .trailing
    }
    
    private lazy var directInputButton = createMenuButton(
        title: "미션 직접 입력하기",
        icon: .icEdit
    ).then {
        $0.tag = 0
        $0.addTarget(self, action: #selector(menuTapped(_:)), for: .touchUpInside)
    }
    
    private lazy var aiInputButton = createMenuButton(
        title: "알림장 한 번에 입력하기",
        icon: .icRobot
    ).then {
        $0.tag = 1
        $0.addTarget(self, action: #selector(menuTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        setAction()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        addSubviews(dimView, stackView)
        stackView.addArrangedSubviews(directInputButton, aiInputButton)
    }
    
    private func setLayout() {
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        stackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(31)
            $0.bottom.equalToSuperview().inset(198)
        }
    }
    
    private func setAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dimView.addGestureRecognizer(tap)
    }
    
    private func createMenuButton(title: String, icon: UIImage?) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .gray900
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)
        
        config.image = icon
        config.imagePlacement = .trailing
        config.imagePadding = 4
        
        let style: UIFont.NotoSans = .title4_14_SB
        
        var titleAttr = AttributedString(title)
        titleAttr.font = style.font
        
        let kernValue = style.size * (style.letterSpacingPercent / 100.0)
        titleAttr.kern = kernValue
        
        config.attributedTitle = titleAttr
        
        return UIButton(configuration: config)
    }
    
    @objc
    private func menuTapped(_ sender: UIButton) {
        onMenuSelected?(sender.tag)
        dismiss()
    }
    
    @objc
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func show(in view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        self.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
}
