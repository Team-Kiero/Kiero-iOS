//
//  MissionView.swift
//  Kiero
//
//  Created by 신혜연 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class MissionView: BaseUIView {
    
    // MARK: - Properties
    
    private var groupedMissions: [String: [Mission]] = [:]
    private var sortedDates: [String] = []
    
    // MARK: - UI Components
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(MissionTableViewCell.self, forCellReuseIdentifier: MissionTableViewCell.identifier)
        $0.dataSource = self
        $0.delegate = self
        $0.sectionHeaderTopPadding = 0
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubview(tableView)
    }
    
    override func setLayout() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateMissions(_ missions: [Mission]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = Date().toString(format: "yyyy-MM-dd")
        let futureMissions = missions.filter { $0.dueAt >= todayString }
        
        groupedMissions = Dictionary(grouping: futureMissions) { $0.dueAt }
        sortedDates = groupedMissions.keys.sorted()
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MissionView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKey = sortedDates[section]
        return groupedMissions[dateKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MissionTableViewCell.identifier, for: indexPath) as? MissionTableViewCell else { return UITableViewCell() }
        
        let dateKey = sortedDates[indexPath.section]
        if let mission = groupedMissions[dateKey]?[indexPath.row] {
            cell.configure(name: mission.name, reward: mission.reward)
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MissionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateString = sortedDates[section]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let headerDate = formatter.date(from: dateString) else { return nil }
        
        let headerView = UIView()
        let containerStack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .leading
        }
        
        let titleLabel = UILabel().then {
            $0.font = .title4_14_SB
            $0.textColor = .gray300
            
            if headerDate.isToday {
                $0.text = "오늘"
                $0.isHidden = false
            } else if headerDate.isTomorrow {
                $0.text = "내일"
                $0.isHidden = false
            } else {
                $0.isHidden = true
            }
        }
        
        let dateLabel = UILabel().then {
            $0.text = headerDate.toString()
            $0.font = .body3_14_R
            $0.textColor = .gray500
        }
        
        headerView.addSubview(containerStack)
        containerStack.addArrangedSubviews(titleLabel, dateLabel)
        
        containerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(section == 0 ? 23 : 16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(11)
        }
        
        return headerView
    }
}

extension Date {
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    func toString(format: String = "yyyy.MM.dd.(E)") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}

#Preview {
    MissionView()
}
