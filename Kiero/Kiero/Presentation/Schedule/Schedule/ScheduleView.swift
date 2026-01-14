//
//  ScheduleView.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import UIKit

import SnapKit
import Then

final class ScheduleView: BaseUIView {
    
    let pagingHeader = PagingHeader()
    let timeTableView = WeeklyTimeTableView()
    
    override func setUI() {
        addSubviews(pagingHeader, timeTableView)
        pagingHeader.configure(title: "12월 2주차", isLeftEnabled: true, isRightEnabled: true)
    }
    
    override func setLayout() {
        pagingHeader.snp.makeConstraints {
            $0.top.equalToSuperview().inset(22)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        timeTableView.snp.makeConstraints {
            $0.top.equalTo(pagingHeader.snp.bottom).offset(18)
            $0.horizontalEdges.bottom.equalToSuperview().inset(23)
        }
    }
    
    func updateSchedules(_ schedules: [MockSchedule]) {
        schedules.forEach {
            timeTableView.addSchedule(schedule: $0)
        }
    }
}

#Preview {
    ScheduleView()
}
