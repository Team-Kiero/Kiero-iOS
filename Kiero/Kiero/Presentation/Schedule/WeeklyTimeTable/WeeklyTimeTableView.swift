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
    
    private let hourHeight: CGFloat = 40
    private let startHour = 8
    private let endHour = 21
    
    // TODO: 데이터 주입
    private var daysDates: [Date] = []
    
    // MARK: - UI Components
    
    private let emptyView = UIView().then {
        $0.isHidden = true
        $0.alpha = 0
    }
    
    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(resource: .icScheduleEmpty)
        $0.contentMode = .scaleAspectFit
    }
    
    private let emptyTitleLabel = UILabel().then {
        $0.setTypo(.title3_16_SB, text: "오늘 등록된 일정이 없어요.")
        $0.textColor = .gray500
        $0.textAlignment = .center
    }
    
    private let emptySubLabel = UILabel().then {
        $0.setTypo(.body4_12_R, text: "우측 하단 버튼을 눌러 일정을 추가해보세요!")
        $0.textColor = .gray700
        $0.textAlignment = .center
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
        
        gridBackgroundView.addSubview(emptyView)
        gridBackgroundView.addSubview(cardContainerView)
        emptyView.addSubviews(emptyImageView, emptyTitleLabel, emptySubLabel)
        
        self.daysDates = Date().daysOfWeek
        updateHeaderLabels()
        setTimeLabel()
    }
    
    override func setLayout() {
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(gridBackgroundView.snp.leading)
            $0.trailing.equalTo(gridBackgroundView.snp.trailing)
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
            $0.height.equalTo(totalGridHeight+10)
        }
        
        gridBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(23)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(totalGridHeight)
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(188)
            $0.horizontalEdges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(52)
            $0.width.equalTo(69)
        }
        
        emptyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(11)
            $0.horizontalEdges.equalToSuperview()
        }
        
        emptySubLabel.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        cardContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
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
                $0.setTypo(.body6_10_R, text: "\(hour)")
                $0.textColor = .gray600
                $0.textAlignment = .center
            }
            timeRowContainer.addSubview(timeLabel)
            
            timeLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(3)
                $0.centerX.equalToSuperview()
            }
            
            if hour > startHour {
                let line = UIView().then { $0.backgroundColor = .gray800 }
                gridContainer.addSubview(line)
                
                line.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(yOffset)
                    $0.leading.equalToSuperview()
                    $0.width.equalTo(23)
                    $0.height.equalTo(0.3)
                }
            }
        }
    }
    
    private func updateHeaderLabels() {
        headerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        headerStackView.isLayoutMarginsRelativeArrangement = true
        headerStackView.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: -10)
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
        emptyView.alpha = 0
        emptyView.isHidden = true
        cardContainerView.layoutIfNeeded()
    }
    
    func scrollToTop() {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func updateEmptyState(isEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if !isEmpty {
                self.emptyView.alpha = 0
                self.emptyView.isHidden = true
            } else {
                self.emptyView.isHidden = false
                UIView.animate(withDuration: 0.4) {
                    self.emptyView.alpha = 1
                }
            }
        }
    }
    
    func addSchedule(schedule: Schedule) {
        let startFloat = convertTimeToFloat(schedule.startTime)
        let endFloat = convertTimeToFloat(schedule.endTime)
        
        var duration = endFloat - startFloat
        if duration <= 0 { duration = 1.0 }
        
        let topOffset = CGFloat(startFloat - Double(startHour)) * hourHeight
        let cardHeight = CGFloat(duration) * hourHeight
        let actualColor = UIColor(hex: schedule.colorCode)
        
        let cardWidth: CGFloat = 44
        let spacing: CGFloat = 3
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dateString = schedule.date,
              let scheduleDate = formatter.date(from: dateString) else { return }
        
        let calendar = Calendar.current
        if let dayIndex = daysDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: scheduleDate) }) {
            
            let card = ScheduleCardView(name: schedule.name, color: actualColor)
            cardContainerView.addSubview(card)
            
            card.snp.makeConstraints {
                $0.top.equalToSuperview().offset(topOffset)
                $0.height.equalTo(cardHeight)
                $0.width.equalTo(cardWidth)
                $0.leading.equalToSuperview().offset(CGFloat(dayIndex) * (cardWidth + spacing))
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
