//
//  WeeklyTimeTableView.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import UIKit

import SnapKit
import Then

final class WeeklyTimeTableView: BaseUIView {
    
    // MARK: - Properties
    
    private let hourHeight: CGFloat = 38.0
    private let startHour = 8
    private let endHour = 22
    
    // TODO: 데이터 주입
    private var daysDates: [Date] = []
    
    // MARK: - UI Components
    
    private let emptyLabel = UILabel().then {
        $0.numberOfLines = 0
        let text = "등록된 일정이 없어요.\n우측 하단 버튼을 눌러 일정을 추가해보세요!"
        $0.setTypo(.title4_14_SB, text: text)
        $0.textAlignment = .center
        $0.textColor = .gray400
        $0.isHidden = false
        $0.alpha = 0
    }
    
    private let headerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let gridContainer = UIView()
    
    private let gridBackgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.gray800.cgColor
        $0.clipsToBounds = false
    }
    
    private let cardContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubviews(headerStackView, scrollView)
        scrollView.addSubview(gridContainer)
        gridContainer.addSubview(gridBackgroundView)
        gridBackgroundView.addSubviews(cardContainerView, emptyLabel)
        
        self.daysDates = Date().daysOfWeek
        updateHeaderLabels()
        setTimeLabel()
    }
    
    override func setLayout() {
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(27)
            $0.trailing.equalToSuperview().inset(5)
            $0.height.equalTo(25)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
        
        let totalGridHeight = CGFloat(endHour - startHour + 1) * hourHeight
        
        gridContainer.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(totalGridHeight)
        }
        
        gridBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(23)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(totalGridHeight)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(155)
        }
        
        cardContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        }
    }
    
    private func setTimeLabel() {
        for hour in startHour...endHour {
            let yOffset = CGFloat(hour - startHour) * hourHeight
            
            let timeRowContainer = UIView()
            gridContainer.addSubview(timeRowContainer)
            
            timeRowContainer.snp.makeConstraints {
                $0.top.equalTo(gridBackgroundView.snp.top).offset(yOffset)
                $0.leading.equalToSuperview()
                $0.width.equalTo(23)
                $0.height.equalTo(hourHeight)
            }
            
            let timeLabel = UILabel().then {
                $0.setTypo(.body5_10_R, text: "\(hour)")
                $0.textColor = .gray600
                $0.textAlignment = .center
            }
            timeRowContainer.addSubview(timeLabel)
            
            timeLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
            }
            
            if hour > startHour {
                let line = UIView().then { $0.backgroundColor = .gray800 }
                gridContainer.addSubview(line)
                
                line.snp.makeConstraints {
                    $0.bottom.equalTo(timeRowContainer.snp.top).offset(-3)
                    $0.leading.equalToSuperview()
                    $0.width.equalTo(23)
                    $0.height.equalTo(0.3)
                }
            }
        }
    }
    
    private func updateHeaderLabels() {
        headerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        daysDates.enumerated().forEach { index, date in
            let itemView = DayItem()
            
            let dayNum = calendar.component(.day, from: date)
            let weekday = date.toString(format: "E")
            let isToday = calendar.isDate(date, inSameDayAs: today)
            
            itemView.configure(day: "\(dayNum)(\(weekday))", isToday: isToday)
            headerStackView.addArrangedSubview(itemView)
        }
    }
    
    func clearSchedules() {
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }
        emptyLabel.alpha = 0
        cardContainerView.layoutIfNeeded()
    }
    
    func scrollToTop() {
        scrollView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func updateEmptyState(isEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if isEmpty {
                UIView.animate(withDuration: 0.4) {
                    self.emptyLabel.alpha = 1
                }
            } else {
                self.emptyLabel.alpha = 0
            }
        }
    }
    
    func addSchedule(schedule: Schedule) {
        let dayIndices = schedule.dayIndices
        let startFloat = convertTimeToFloat(schedule.startTime)
        let endFloat = convertTimeToFloat(schedule.endTime)
        
        var duration = endFloat - startFloat
        if duration <= 0 { duration = 1.0 }
        
        let topOffset = CGFloat(startFloat - Double(startHour)) * hourHeight
        let cardHeight = CGFloat(duration) * hourHeight
        let actualColor = UIColor(hex: schedule.colorCode)
        
        dayIndices.forEach { dayIndex in
            let card = ScheduleCardView(name: schedule.name, color: actualColor)
            cardContainerView.addSubview(card)
            
            card.snp.makeConstraints {
                $0.top.equalToSuperview().offset(topOffset)
                $0.height.equalTo(cardHeight)
                $0.width.equalToSuperview().multipliedBy(1.0 / 7.0).inset(2)
                $0.centerX.equalToSuperview().multipliedBy((CGFloat(dayIndex) + 0.5) / 3.5)
            }
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func convertTimeToFloat(_ time: String) -> Double {
        let formatter = DateFormatter()
        let formats = ["HH:mm:ss", "hh : mm a", "HH:mm"]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: time) {
                let calendar = Calendar.current
                let hour = Double(calendar.component(.hour, from: date))
                let minute = Double(calendar.component(.minute, from: date))
                return hour + (minute / 60.0)
            }
        }
        
        return 0.0
    }
    
    func updateDaysDates(_ dates: [Date]) {
        self.daysDates = dates
        updateHeaderLabels()
    }
}

#Preview {
    WeeklyTimeTableView()
}
