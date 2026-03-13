import Foundation

final class TodayStatusService {
    
    static let shared = TodayStatusService()
    private init() {}
    
    private let baseService = BaseService.shared
    
    func fetchTodayStatus() async throws -> TodayStatusDTO {
        try await baseService.request(
            endPoint: TodayStatusEndPoint.fetchTodayStatus
        )
    }
    
    func fetchScheduleImage(scheduleDetailId: Int) async throws -> ScheduleImageDTO {
        try await baseService.request(
            endPoint: TodayStatusEndPoint.fetchScheduleImage(scheduleDetailId: scheduleDetailId)
        )
    }
}