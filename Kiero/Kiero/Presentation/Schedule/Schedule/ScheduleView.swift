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
    
    private var currentSchedules: [Schedule] = []
    
    let pagingHeader = PagingHeader()
    let timeTableView = WeeklyTimeTableView()
    
    override func setUI() {
        addSubviews(pagingHeader, timeTableView)
        
        let today = Date()
        pagingHeader.configure(title: today.weekOfMonthString, isLeftEnabled: true, isRightEnabled: true)
    }
    
    override func setLayout() {
        pagingHeader.snp.makeConstraints {
            $0.top.equalToSuperview().inset(22)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        timeTableView.snp.makeConstraints {
            $0.top.equalTo(pagingHeader.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(23)
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateSchedules(_ schedules: [Schedule]) {
        self.currentSchedules = schedules
        
        UIView.performWithoutAnimation {
            timeTableView.clearSchedules()
            
            schedules.forEach { schedule in
                timeTableView.addSchedule(schedule: schedule)
            }
            
            self.timeTableView.setNeedsLayout()
            self.timeTableView.layoutIfNeeded()
        }
        
        timeTableView.updateEmptyState(isEmpty: schedules.isEmpty)
    }
}

#Preview {
    ScheduleView()
}
