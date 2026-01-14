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
    private let days = ["8(월)", "9(화)", "10(수)", "11(목)", "12(금)", "13(토)", "14(일)"]
    
    // MARK: - UI Components
    
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
        $0.clipsToBounds = true
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubviews(headerStackView, scrollView)
        scrollView.addSubview(gridContainer)
        gridContainer.addSubview(gridBackgroundView)
        
        days.enumerated().forEach { index, day in
            let itemView = DayItem()
            itemView.configure(day: day, isToday: index == 0)
            headerStackView.addArrangedSubview(itemView)
        }
        
        setTimeLabel()
    }
    
    override func setLayout() {
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(34)
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
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(totalGridHeight)
        }
    }
    
    private func setTimeLabel() {
        for hour in startHour...endHour {
            let yOffset = CGFloat(hour - startHour) * hourHeight
            
            let timeRowContainer = UIView()
            gridContainer.addSubview(timeRowContainer)
            
            timeRowContainer.snp.makeConstraints {
                $0.top.equalTo(gridBackgroundView.snp.top).offset(yOffset)
                $0.leading.equalToSuperview().inset(9)
                $0.width.equalTo(23)
                $0.height.equalTo(hourHeight)
            }
            
            let timeLabel = UILabel().then {
                $0.text = "\(hour)"
                $0.font = .body5_10_R
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
                    $0.leading.equalToSuperview().inset(9)
                    $0.width.equalTo(23)
                    $0.height.equalTo(0.3)
                }
            }
        }
    }
    
    func addSchedule(schedule: MockSchedule) {
        let card = ScheduleCardView(name: schedule.name, colorCode: schedule.colorCode)
        gridBackgroundView.addSubview(card)
        
        let startFloat = convertTimeToFloat(schedule.startTime)
        let endFloat = convertTimeToFloat(schedule.endTime)
        var topOffset = CGFloat(startFloat - Double(startHour)) * hourHeight
        var height = CGFloat(endFloat - startFloat) * hourHeight
        
        if Int(startFloat) == startHour {
            topOffset += 4
            height -= 4
        }
        
        if Int(endFloat) == endHour {
            height -= 4
        }
        
        if Int(startFloat) != startHour {
            topOffset += 1
            height -= 1
        }
        if Int(endFloat) != endHour {
            height -= 1
        }
        
        let cardWidth: CGFloat = 40
        
        guard schedule.dayIndex < headerStackView.arrangedSubviews.count else { return }
        let targetDayView = headerStackView.arrangedSubviews[schedule.dayIndex]
        
        card.snp.makeConstraints {
            $0.top.equalToSuperview().offset(topOffset)
            $0.height.equalTo(height)
            $0.width.equalTo(cardWidth)
            $0.centerX.equalTo(targetDayView.snp.centerX)
        }
        
        card.layoutIfNeeded()
    }
    
    private func convertTimeToFloat(_ time: String) -> Double {
        let parts = time.split(separator: ":").compactMap { Double($0) }
        guard parts.count >= 2 else { return 0 }
        return parts[0] + (parts[1] / 60.0)
    }
}

#Preview {
    WeeklyTimeTableView()
}
