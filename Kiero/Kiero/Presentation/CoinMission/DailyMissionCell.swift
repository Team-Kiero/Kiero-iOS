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
    var missionTapHandler : ((Int64, String) -> Void)?
    
    // MARK: - UI Components
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray200
    }
    
    private let missionStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 18
        $0.alignment = .fill
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
    
    func configure(dueAt: String, dayOfWeek: String, missions: [MissionItemDTO]) {
        dateLabel.setTypo(.body4_12_R, text: dueAt.toMissionDateString(dayOfWeek: dayOfWeek))
        missionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for mission in missions {
            let missionView = createMissionView(from: mission)
            missionStack.addArrangedSubview(missionView)
        }
    }
    
    private func createMissionView(from mission: MissionItemDTO) -> MissionBoxChild {
        let missionView = MissionBoxChild()
        let state: MissionBoxChild.State = mission.isCompleted ? .completed : .inProgress
        
        missionView.configure(name: mission.name, reward: mission.reward, state: state)
        missionView.onTap = { [weak self] in
            self?.missionTapHandler?(Int64(mission.id), mission.name)
        }
        return missionView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        missionTapHandler = nil
    }
}

extension String {
    
    func toMissionDateString(dayOfWeek: String) -> String {
        let parsed = self.toDateFlexible()
        
        if let date = parsed {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) { return "오늘까지" }
            if calendar.isDateInTomorrow(date) { return "내일까지" }
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M월 d일 \(dayOfWeek)까지"
            return formatter.string(from: date)
        }
        
        return "\(self) \(dayOfWeek)까지"
    }
    
    private func toDateFlexible() -> Date? {
        let fmts = ["yyyy.MM.dd", "yyyy-MM-dd", "yyyy/MM/dd"]
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        for fmt in fmts {
            f.dateFormat = fmt
            if let d = f.date(from: self) { return d }
        }
        return nil
    }
}
