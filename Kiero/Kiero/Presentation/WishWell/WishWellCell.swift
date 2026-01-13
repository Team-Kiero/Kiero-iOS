//
//  WishWellCell.swift
//  Kiero
//
//  Created by 정윤아 on 1/12/26.
//

import UIKit

import SnapKit
import Then

final class WishWellCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "WishWellCell"
    var onTapComplete: (() -> Void)?
    
    // MARK: - UI Components
    
    private let wishBox = WishBox()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        contentView.addSubview(wishBox)
    }
    
    private func setLayout() {
        wishBox.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        wishBox.onTap = { [weak self] in
            self?.onTapComplete?()
        }
    }
    
    // MARK: - Configuration
    
    func configure(name: String, price: Int) {
        wishBox.configure(name: name, price: price)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onTapComplete = nil
    }
}
