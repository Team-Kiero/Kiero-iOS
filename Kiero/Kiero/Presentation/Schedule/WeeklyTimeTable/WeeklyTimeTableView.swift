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
    private let spacing: CGFloat = 3
    private let verticalPadding: CGFloat = 4
    private let timeLabelWidth: CGFloat = 23
    
    private var daysDates: [Date] = []
    var onScheduleTap: ((Schedule) -> Void)?
    
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
        gridBackgroundView.addSubviews(emptyView, cardContainerView)
        emptyView.addSubviews(emptyImageView, emptyTitleLabel, emptySubLabel)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 190, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 190, right: 0)
        
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
            $0.bottom.equalToSuperview()
        }
        
        let totalGridHeight = CGFloat(endHour - startHour + 1) * hourHeight
        
        gridContainer.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(totalGridHeight + (verticalPadding * 2))
        }
        
        gridBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(timeLabelWidth)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(totalGridHeight + (verticalPadding * 2))
        }
        
        cardContainerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(verticalPadding)
            $0.leading.trailing.equalToSuperview().inset(4)
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(188)
            $0.horizontalEdges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 69, height: 52))
        }
        
        emptyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(11)
            $0.horizontalEdges.equalToSuperview()
        }
        
        emptySubLabel.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setTimeLabel() {
        gridContainer.subviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }
        gridBackgroundView.subviews.forEach {
            if $0 != cardContainerView && $0 != emptyView {
                $0.removeFromSuperview()
            }
        }

        for hour in startHour...endHour {
            let yOffset = CGFloat(hour - startHour) * hourHeight
            
            if hour > startHour {
                let line = UIView().then {
                    $0.backgroundColor = .gray800
                }
                gridBackgroundView.addSubview(line)
                
                line.snp.makeConstraints {
                    $0.centerY.equalTo(cardContainerView.snp.top).offset(yOffset)
                    $0.leading.equalToSuperview().offset(-timeLabelWidth)
                    $0.trailing.equalTo(gridBackgroundView.snp.leading)
                    $0.height.equalTo(0.5)
                }
                
                let timeLabel = UILabel().then {
                    $0.setTypo(.body6_10_R, text: "\(hour)")
                    $0.textColor = .gray600
                    $0.textAlignment = .center
                }
                gridContainer.addSubview(timeLabel)
                
                timeLabel.snp.makeConstraints {
                    $0.top.equalTo(line.snp.centerY).offset(5)
                    $0.centerX.equalTo(line.snp.leading).offset(timeLabelWidth / 2)
                }
            } else {
                let timeLabel = UILabel().then {
                    $0.setTypo(.body6_10_R, text: "\(hour)")
                    $0.textColor = .gray600
                    $0.textAlignment = .center
                }
                gridContainer.addSubview(timeLabel)
                
                timeLabel.snp.makeConstraints {
                    $0.top.equalTo(gridBackgroundView.snp.top).offset(verticalPadding + 5)
                    $0.leading.equalToSuperview()
                    $0.width.equalTo(timeLabelWidth)
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
                UIView.animate(withDuration: 0.4) { self.emptyView.alpha = 1 }
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
        
        self.layoutIfNeeded()
        let totalWidth = cardContainerView.bounds.width
        let cardWidth = (totalWidth - CGFloat(6) * spacing) / 7
        
        guard let dateString = schedule.date,
              let scheduleDate = dateString.toDate() else { return }
        
        if let dayIndex = daysDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: scheduleDate) }) {
            let card = ScheduleCardView(name: schedule.name, color: actualColor)
            card.tapAction = { [weak self] in self?.onScheduleTap?(schedule) }
            
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
