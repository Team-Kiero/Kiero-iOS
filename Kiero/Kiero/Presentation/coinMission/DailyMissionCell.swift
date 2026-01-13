//
//  DailyMissionCell.swift
//  Kiero
//
//  Created by 정윤아 on 1/13/26.
//

import UIKit

import SnapKit
import Then

class DailyMissionCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "DailyMissionCell"
    
    // MARK: - UI Components
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray200
    }
    
    private let missionStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 18
        $0.distribution = .fill
    }
    
    // MARK: - Init
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        contentView.addSubviews(dateLabel, missionStack)
    }
    
    private func setLayout() {
        dateLabel.snp.makeConstraints {
            $0.height.equalTo(14)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
        
        missionStack.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(15.5)
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    
    func configure(date: Date, missions: [(name: String, reward: Int, isCompleted: Bool)]) {
        dateLabel.setTypo(.body4_12_R, text: date.toMissionDateString())
        missionStack.arrangedSubviews.forEach { $0.removeFromSuperview()}
        
        for mission in missions {
            let missionView = MissionBoxChild()
            let state: MissionBoxChild.State = mission.isCompleted ? .completed : .inProgress
            
            missionView.configure(name: mission.name, reward: mission.reward, state: state)
            
            missionView.onTap = {
                print("\(mission.name) 완료 버튼 클릭")
            }
            missionStack.addArrangedSubview(missionView)
        }
    }
}

extension Date {
    func toMissionDateString() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "오늘 까지"}
        else if calendar.isDateInTomorrow(self) { return "내일 까지" }
        else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M월 d일 E요일"
            return formatter.string(from: self)
        }
    }
}
