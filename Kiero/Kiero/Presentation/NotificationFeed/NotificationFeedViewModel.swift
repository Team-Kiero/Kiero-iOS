//
//  NotificationFeedViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//
import UIKit
import Combine

final class NotificationFeedViewModel: BaseViewModel {
    
    struct Section {
        let date: String
        var items: [NotificationFeed.State]
    }
    
    var sections: [Section] = []
    var onDataUpdated: (() -> Void)?
    
    // MARK: - Formatter
    
    private let serverFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()
    
    private let sectionFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy.MM.dd.(E)"
        return f
    }()
    
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "HH : mm"
        return f
    }()
    
    func fetchNotifications() {
        let events = makeMockEvents()
        self.sections = buildSections(from: events)
        onDataUpdated?()
    }
    
    func toggleExpansion(at indexPath: IndexPath) {
        let currentState = sections[indexPath.section].items[indexPath.row]
        
        switch currentState {
        case let .finishSchedule(time, name, schedule, image, isExpanded):
            sections [indexPath.section].items[indexPath.row] = .finishSchedule(
                time: time,
                childName: name,
                schedule: schedule,
                proofImage: image,
                isExpanded: !isExpanded
            )
        default:
            break
        }
    }
}

private extension NotificationFeedViewModel {
    
    struct MockEvent {
        let eventType: String
        let occurredAt: String
        let childName: String
        let content: String?
        let amount: Int?
        let proofImage: UIImage?
        let schedule: String?
        let mission: String?
    }
    
    func makeMockEvents() -> [MockEvent] {
        let image = UIImage(resource: .test)
        
        return [
            .init(eventType: "COUPON", occurredAt: "2026-01-10 12:12",
                  childName: "근영", content: "게임 30분 추가", amount: 150, proofImage: nil,
                  schedule: nil, mission: nil),
            
                .init(eventType: "FINISH_SCHEDULE", occurredAt: "2026-01-10 12:00",
                      childName: "근영", content: nil, amount: nil, proofImage: image,
                      schedule: "피아노 학원", mission: nil),
            
                .init(eventType: "MISSION", occurredAt: "2026-01-10 09:40",
                      childName: "근영", content: nil, amount: 30, proofImage: nil,
                      schedule: nil, mission: "책읽기"),
            
                .init(eventType: "ALL_SCHEDULE", occurredAt: "2026-01-09 22:20",
                      childName: "근영", content: nil, amount: 10, proofImage: nil,
                      schedule: nil, mission: nil),
            
                .init(eventType: "MISSION", occurredAt: "2026-01-09 18:20",
                      childName: "근영", content: nil, amount: 150, proofImage: nil,
                      schedule: nil, mission: "방청소하기"),
            
                .init(eventType: "COUPON", occurredAt: "2026-01-08 20:05",
                      childName: "근영", content: "유튜브 20분 추가", amount: 80, proofImage: nil,
                      schedule: nil, mission: nil),
        ]
    }
    
    func buildSections(from events: [MockEvent]) -> [Section] {
        let mapped: [(date: Date, state: NotificationFeed.State)] = events.compactMap(mapToState)
        let grouped = Dictionary(grouping: mapped) { Calendar.current.startOfDay(for: $0.date) }
        let sortedDays = grouped.keys.sorted(by: >)
        return sortedDays.map { day in
            let items = (grouped[day] ?? []).map { $0.state }
            return Section(
                date: sectionFormatter.string(from: day),
                items: items
            )
        }
    }
    
    func mapToState(_ event: MockEvent) -> (date: Date, state: NotificationFeed.State)? {
        guard let date = serverFormatter.date(from: event.occurredAt) else { return nil }
        let timeText = timeFormatter.string(from: date)
        
        switch event.eventType {
        case "FINISH_SCHEDULE":
            return (date, .finishSchedule(
                time: timeText,
                childName: event.childName,
                schedule: event.schedule ?? "일정",
                proofImage: event.proofImage,
                isExpanded: false
            ))
        case "COUPON":
            return (date, .useCoupon(
                time: timeText,
                childName: event.childName,
                coupon: event.content ?? "쿠폰",
                coinUsed: event.amount ?? 0
            ))
        case "ALL_SCHEDULE":
            return (date, .finishAllSchedule(
                time: timeText,
                childName: event.childName,
                coinEarned: event.amount ?? 0
            ))
        case "MISSION":
            return (date, .finishMission(
                time: timeText,
                childName: event.childName,
                mission: event.mission ?? "미션",
                coinEarned: event.amount ?? 0
            ))
        default:
            return nil
        }
    }
}
