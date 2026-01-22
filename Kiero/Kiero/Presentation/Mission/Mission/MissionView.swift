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
    private var missionGroups: [MissionGroupDTO] = []
    
    // MARK: - UI Components
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(MissionTableViewCell.self, forCellReuseIdentifier: MissionTableViewCell.identifier)
        $0.dataSource = self
        $0.delegate = self
        $0.sectionHeaderTopPadding = 0
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        $0.contentInsetAdjustmentBehavior = .never
    }
    
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
        let todayString = Date().toString(format: "yyyy-MM-dd")
        let futureMissions = missions.filter { $0.dueAt >= todayString }
        
        groupedMissions = Dictionary(grouping: futureMissions) { $0.dueAt }
        sortedDates = groupedMissions.keys.sorted()
        
        tableView.reloadData()
    }
    
    func updateMissionGroups(_ groups: [MissionGroupDTO]) {
        self.missionGroups = groups
        self.tableView.reloadData()
    }
    
    func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated: false)
    }
}

// MARK: - UITableViewDataSource

extension MissionView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return missionGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missionGroups[section].missions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MissionTableViewCell.identifier, for: indexPath) as? MissionTableViewCell else {
            return UITableViewCell()
        }
        
        let mission = missionGroups[indexPath.section].missions[indexPath.row]
        cell.configure(name: mission.name, reward: mission.reward)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MissionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let group = missionGroups[section]
        let dateString = group.dueAt
        
        guard let headerDate = dateString.toDate(format: "yyyy-MM-dd") else { return nil }
        
        let headerView = UIView().then {
            $0.backgroundColor = .kBlack
        }
        let containerStack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .leading
            $0.backgroundColor = .kBlack
        }
        
        let titleLabel = UILabel().then {
            $0.textColor = .gray300
            if headerDate.isToday {
                $0.setTypo(.title4_14_SB, text: "오늘")
                $0.isHidden = false
            } else if headerDate.isTomorrow {
                $0.setTypo(.title4_14_SB, text: "내일")
                $0.isHidden = false
            } else {
                $0.isHidden = true
            }
        }
        
        let dateLabel = UILabel().then {
            $0.text = "\(headerDate.toString(format: "yyyy.MM.dd."))(\(group.dayOfWeek))"
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

#Preview {
    MissionView()
}
