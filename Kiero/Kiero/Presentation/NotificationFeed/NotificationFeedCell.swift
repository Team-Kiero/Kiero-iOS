//
//  NotificationFeedCell.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//

import UIKit

import SnapKit

final class NotificationFeedCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "NotificationFeedCell"
    private let feedView = NotificationFeed()
    
    var onToggleExpand: (() -> Void)? {
        didSet { feedView.onToggleExpand = onToggleExpand }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func setUI() {
        contentView.addSubview(feedView)
    }
    
    private func setLayout() {
        feedView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview().inset(15.5)
            $0.bottom.equalToSuperview().inset(6)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with state: NotificationFeed.State) {
        feedView.configure(state)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedView.resetForReuse()
        onToggleExpand = nil
    }
}
