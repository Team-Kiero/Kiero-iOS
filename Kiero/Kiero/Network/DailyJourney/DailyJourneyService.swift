//
//  DailyJourneyService.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/20/26.
//

import Combine
import UIKit

final class DailyJourneyService {
    static let shared = DailyJourneyService()
    private init() {}
    
    func updateDailyJourney() -> AnyPublisher<DailyJourneyDTO, NetworkError> {
        return Future<DailyJourneyDTO, NetworkError> { promise in
            Task {
                do {
                    let response: DailyJourneyDTO = try await BaseService.shared.request(
                        endPoint: .updateDailyJourney,
                        body: nil
                    )
                    promise(.success(response))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func skipJourney(scheduleDetailId: Int) -> AnyPublisher<DailyJourneyDTO, NetworkError> {
        return Future<DailyJourneyDTO, NetworkError> { promise in
            Task {
                do {
                    let response: DailyJourneyDTO = try await BaseService.shared.request(
                        endPoint: .skipJourney(scheduleDetailId: scheduleDetailId),
                        body: nil
                    )
                    promise(.success(response))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func verifyJourney(scheduleDetailId: Int, image: UIImage) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                        promise(.failure(.unknownError))
                        return
                    }
                    
                    let uniqueFileName = "\(UUID().uuidString).jpg"
                    let presignedRequestBody = JourneyVerificationDTO.PresignedURLRequest(
                        fileName: uniqueFileName,
                        contentType: "image/jpeg"
                    )
                    
                    let presignedData: JourneyVerificationDTO.PresignedResult = try await BaseService.shared.request(
                        endPoint: .getPresignedURL,
                        body: presignedRequestBody
                    )
                    
                    let s3UrlString = presignedData.presignedUrl
                    let cleanImageUrl = s3UrlString.components(separatedBy: "?").first ?? s3UrlString
                    
                    guard let s3Url = URL(string: s3UrlString) else {
                        promise(.failure(.invalidURL))
                        return
                    }
                    
                    var s3Request = URLRequest(url: s3Url)
                    s3Request.httpMethod = "PUT"
                    s3Request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                    
                    print("📤 S3 업로딩 시작")
                    let (data, response) = try await URLSession.shared.upload(for: s3Request, from: imageData)
                    
                    guard let s3HttpRes = response as? HTTPURLResponse else {
                        promise(.failure(.unknownError))
                        return
                    }
                    
                    NetworkLogger.shared.responseLog(s3HttpRes, data: data)
                    
                    if !(200...299).contains(s3HttpRes.statusCode) {
                        throw NetworkError.clientError(statusCode: s3HttpRes.statusCode)
                    }
                    
                    let requestBody = JourneyVerificationDTO.CompleteRequest(imageUrl: cleanImageUrl)
                    
                    print("📤 completeSchedule API 호출 시작")
                    
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: .completeSchedule(scheduleDetailId: scheduleDetailId),
                        body: requestBody
                    )
                    print("✅ completeSchedule API 응답 수신")
                    print("✅ 모든 과정 성공 (DB 저장 URL: \(cleanImageUrl))")
                    promise(.success(()))
                    
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func lightFire() -> AnyPublisher<FireLitData, NetworkError> {
        return Future<FireLitData, NetworkError> { promise in
            Task {
                do {
                    let data: FireLitData = try await BaseService.shared.request(
                        endPoint: .fireLit,
                        body: nil
                    )
                    promise(.success(data))
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    print("❌ [LightFire] Unexpected Error: \(error)")
                    promise(.failure(.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

