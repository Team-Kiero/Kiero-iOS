//
//  ProfileBox.swift
//  Kiero
//
//  Created by 안치욱 on 1/14/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ProfileBox: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Life Cycle
    
    init(name: String, profileURL: String) {
        super.init(frame: .zero)
        setStyle()
        setUI()
        setLayout()
        setAction()
        configure(name: name, url: profileURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting Methods
    
    private func setStyle() {
        backgroundColor = .kBlack
        layer.cornerRadius = 12
    }
    
    private func setUI() {
        addSubviews(
            nameLabel,
            profileImageView
        )
    }
    
    private func setLayout() {
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(21)
            $0.trailing.equalTo(profileImageView.snp.leading).offset(-5)
        }
        
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.trailing.equalToSuperview().inset(21)
            $0.size.equalTo(30)
        }
    }
    
    private func setAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        addGestureRecognizer(tap)
    }
    
    private func configure(name: String, url: String?) {
        nameLabel.setTypo(.body2_16_R, text: name)
        profileImageView.kf.setImage(with: URL(string: url ?? ""), placeholder: UIImage.icParentProfile)
    }
    
    @objc
    private func viewDidTap() {
        onTap?()
    }
}
