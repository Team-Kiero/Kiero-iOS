//
//  DetailBottomSheet.swift
//  Kiero
//
//  Created by 신혜연 on 2/28/26.
//

import UIKit

import SnapKit
import Then

enum DetailType {
    case schedule(isRecurring: Bool, date: String?, days: String?, time: String)
    case mission(dueAt: String, reward: Int)
    case reward(price: Int)
}

struct DetailModel {
    let title: String
    let type: DetailType
}

final class DetailBottomSheet: BaseBottomSheetViewController {
    
    // MARK: - Properties
    
    var onEditTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(resource: .icClose), for: .normal)
        $0.tintColor = .white
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray400
        $0.numberOfLines = 0
    }
    
    private let pointChip = ChipItem()
    
    private let editButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .icEdit)
        config.imagePadding = 12
        config.baseForegroundColor = .white
        $0.configuration = config
        $0.contentHorizontalAlignment = .left
        $0.setTypo(.body4_12_R, text: "수정하기")
    }
    
    private let deleteButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .icDelete)
        config.imagePadding = 12
        config.baseForegroundColor = .white
        $0.configuration = config
        $0.contentHorizontalAlignment = .left
        $0.setTypo(.body4_12_R, text: "삭제하기")
    }
    
    // MARK: - Life Cycle
    
    init(data: DetailModel) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            self.updateData(data)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setAction()
    }
    
    // MARK: - Setting Methods
    
    private func setUI() {
        containerView.addSubviews(
            titleLabel, closeButton, dateLabel, pointChip,
            deleteButton, editButton
        )
    }
    
    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(254)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.leading.equalToSuperview().inset(16)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(titleLabel)
        }
        
        pointChip.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }
        
        deleteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(36)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        
        editButton.snp.makeConstraints {
            $0.bottom.equalTo(deleteButton.snp.top).offset(-4)
            $0.horizontalEdges.height.equalTo(deleteButton)
        }
    }
    
    private func setAction() {
        closeButton.addTarget(self, action: #selector(hideSheet), for: .touchUpInside)
        
        editButton.addAction(UIAction { [weak self] _ in
            self?.hideSheet()
            self?.onEditTap?()
        }, for: .touchUpInside)
        
        deleteButton.addAction(UIAction { [weak self] _ in
            self?.hideSheet()
            self?.onDeleteTap?()
        }, for: .touchUpInside)
    }
    
    private func updateData(_ data: DetailModel) {
        titleLabel.setTypo(.head3_16_B, text: data.title)
        
        switch data.type {
        case .schedule(let isRecurring, let date, let days, let time):
            let formattedDate = stringToDate(date ?? "")?.toFullDateString ?? (date ?? "")
            
            var fullDateInfo = "\(formattedDate)\n\(time)"
            if isRecurring {
                let recurringText = "매주 \(days ?? "") 반복"
                fullDateInfo += "\n\(recurringText)"
            }
            
            dateLabel.setTypo(.body4_12_R, text: fullDateInfo)
            dateLabel.numberOfLines = 0
            pointChip.isHidden = true
            
        case .mission(let dueAt, let reward):
            let formattedDate = stringToDate(dueAt)?.toFullDateString ?? dueAt
            dateLabel.setTypo(.body4_12_R, text: formattedDate)
            dateLabel.numberOfLines = 1
            
            pointChip.configure(style: .usedCoinChip, icon: .ic3DCoin, text: "\(reward) 개")
            pointChip.isHidden = false
            
        case .reward(let price):
            dateLabel.text = ""
            pointChip.configure(style: .usedCoinChip, icon: .ic3DCoin, text: "\(price) 개")
            pointChip.isHidden = false
        }
    }
    
    private func updateButtonLayout(isPointVisible: Bool) {
        editButton.snp.remakeConstraints {
            $0.top.equalTo(isPointVisible ? pointChip.snp.bottom : dateLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(48)
        }
    }
    
    private func stringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}
