//
//  DailyJourneyService.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/20/26.
//

import UIKit
import Combine

final class DailyJourneyService {
    static let shared = DailyJourneyService()
    private init() {}
    
    // 1. 오늘의 여정 조회
    func updateDailyJourney() -> AnyPublisher<DailyJourneyDTO, NetworkError> {
        return Future<DailyJourneyDTO, NetworkError> { promise in
            Task {
                do {
                    // BaseService가 async 기반이라면 await로 호출
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
    
    // 2. 건너뛰기
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
    
    // MARK: - 3. 인증하기 (Presigned URL -> S3 Upload -> Complete)
    
    func verifyJourney(scheduleDetailId: Int, image: UIImage) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            Task {
                do {
                    // -----------------------------------------------------
                    // 0. 이미지 압축
                    // -----------------------------------------------------
                    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                        print("❌ [Image] Encoding Failed")
                        promise(.failure(.unknownError))
                        return
                    }
                    
                    
                    // -----------------------------------------------------
                    // Step 1: Presigned URL 발급
                    // -----------------------------------------------------
                    // BaseService가 로그와 에러 처리를 자동으로 수행
                    let presignedData: JourneyVerificationDTO.PresignedResult = try await BaseService.shared.request(
                        endPoint: .getPresignedURL
                    )
                    
                    let s3UrlString = presignedData.presignedUrl
                    let finalFileName = presignedData.fileName
                    
                    
                    // -----------------------------------------------------
                    // Step 2: S3 업로드 (직접 URLSession 이용)
                    // -----------------------------------------------------
                    guard let s3Url = URL(string: s3UrlString) else {
                        promise(.failure(.invalidURL))
                        return
                    }
                    
                    var s3Request = URLRequest(url: s3Url)
                    s3Request.httpMethod = "PUT"
                    s3Request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                    
                    print("📤 [S3 Upload] Start uploading...")
                    
                    let (data, response) = try await URLSession.shared.upload(for: s3Request, from: imageData)
                    
                    guard let s3HttpRes = response as? HTTPURLResponse else {
                        promise(.failure(.unknownError))
                        return
                    }
                    
                    // ★ [추가됨] S3 응답 로그 찍기
                    NetworkLogger.shared.responseLog(s3HttpRes, data: data)
                    
                    // ★ [추가됨] 상태 코드별 정확한 NetworkError 매핑
                    switch s3HttpRes.statusCode {
                    case 200...299:
                        break // 성공
                    case 400...499:
                        throw NetworkError.clientError(statusCode: s3HttpRes.statusCode)
                    case 500...599:
                        throw NetworkError.internalServerError
                    default:
                        throw NetworkError.unknownError
                    }
                    
                    
                    // -----------------------------------------------------
                    // Step 3: 서버에 완료 요청
                    // -----------------------------------------------------
                    let requestBody = JourneyVerificationDTO.CompleteRequest(imageUrl: finalFileName)
                    
                    // 응답 data가 null이므로 'EmptyResponse' 타입 지정
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: .completeSchedule(scheduleDetailId: scheduleDetailId),
                        body: requestBody
                    )
                    
                    // 모든 과정 성공
                    print("✅ [Verify] Process Completed Successfully")
                    promise(.success(()))
                    
                } catch let error as NetworkError {
                    promise(.failure(error))
                } catch {
                    print("❌ [Verify] Unexpected Error: \(error)")
                    promise(.failure(.unknownError))
                }
            }
        }.eraseToAnyPublisher()
    }
}

