//
//  EndDateViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class EndDateViewController: BaseBottomSheetViewController {
    
    // MARK: - Properties
    
    private let calendar = Calendar.current
    private var baseDate = Date()
    private var days = [Date?]()
    private var selectedDate = Date()
    var onDateSelected: ((Date) -> Void)?
    
    // MARK: - UI Components
    
    private let navigationBar = NavigationBar(type: .closeDone(title: "마감일"), backgroundColor: .gray900)
    
    private let headerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private lazy var prevButton = UIButton().then {
        $0.setImage(UIImage(resource: .icLeft), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
    }
    
    private let monthLabel = UILabel().then {
        $0.font = .body2_16_R
        $0.textColor = .white
    }
    
    private lazy var nextButton = UIButton().then {
        $0.setImage(UIImage(resource: .icRight), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    private let weekdayStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 8
        $0.minimumInteritemSpacing = 0
    }).then {
        $0.backgroundColor = .clear
        $0.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.isScrollEnabled = false
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyle()
        setUI()
        setLayout()
        updateCalendar()
        setAction()
    }
    
    private func setStyle() {
        navigationBar.updateTitle("마감일")
    }
    
    private func setUI() {
        containerView.addSubviews(navigationBar, headerStackView, weekdayStackView, collectionView)
        headerStackView.addArrangedSubviews(prevButton, monthLabel, nextButton)
        
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        weekdays.forEach { title in
            let label = UILabel().then {
                $0.text = title
                $0.font = .body3_14_R
                $0.textColor = .white
                $0.textAlignment = .center
            }
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    private func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }
        
        prevButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        nextButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        headerStackView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(37)
        }
        
        weekdayStackView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(37)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekdayStackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(37)
            $0.height.equalTo(212)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func updateCalendar() {
        days.removeAll()
        let components = calendar.dateComponents([.year, .month], from: baseDate)
        guard let firstDayOfMonth = calendar.date(from: components) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        monthLabel.text = formatter.string(from: baseDate)
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = firstWeekday - 1

        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i - offset, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        collectionView.reloadData()
    }
    
    @objc private func didTapPrev() {
        baseDate = calendar.date(byAdding: .month, value: -1, to: baseDate) ?? Date()
        updateCalendar()
    }
    
    @objc private func didTapNext() {
        baseDate = calendar.date(byAdding: .month, value: 1, to: baseDate) ?? Date()
        updateCalendar()
    }
    
    private func setAction() {
        navigationBar.leftButtonAction = { [weak self] in self?.hideSheet() }
        navigationBar.rightButtonAction = { [weak self] in
            guard let self = self else { return }
            self.onDateSelected?(self.selectedDate)
            self.hideSheet()
        }
    }
    
    func setInitialDate(_ date: Date) {
        self.selectedDate = date
        self.baseDate = date
    }
}

// MARK: - UICollectionViewDataSource

extension EndDateViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell,
              let date = days[indexPath.item] else { return UICollectionViewCell() }
        
        let isCurrentMonth = calendar.isDate(date, equalTo: baseDate, toGranularity: .month)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        let isEnabled = targetDate >= today
        
        cell.configure(
            date: calendar.component(.day, from: date),
            isCurrentMonth: isCurrentMonth,
            isSelected: isSelected,
            isToday: isToday,
            isEnabled: isEnabled
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EndDateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = days[indexPath.item] else { return }
        
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        
        if targetDate >= today {
            self.selectedDate = date
            collectionView.reloadData()
        }
    }
}

#Preview {
    EndDateViewController()
}
