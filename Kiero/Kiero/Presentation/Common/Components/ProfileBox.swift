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
    
    override var backgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
    }
    
    private let nameLabel = UILabel().then {
        
        $0.textColor = .white
        $0.textAlignment = .right
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Life Cycle
    
    init(name: String, profileURL: String, backgroundColor: UIColor = .kBlack) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        
        setUI()
        setLayout()
        setAction()
        configure(name: name, url: profileURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting Methods
    
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
            $0.trailing.equalTo(profileImageView.snp.leading).inset(-5)
        }
        
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(30)
        }
    }
    
    private func setAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        addGestureRecognizer(tap)
    }
    
    func configure(name: String, url: String?) {
        nameLabel.setTypo(.body2_16_R, text: name)
        let imageURL = URL(string: url ?? "")
        profileImageView.kf.setImage(with: imageURL, placeholder: UIImage.icParentProfile)
    }
    
    @objc
    private func viewDidTap() {
        onTap?()
    }
}
