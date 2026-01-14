//
//  ViewControllerFactory.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

public protocol ViewControllerFactory {
    // 부모 탭
    func makeScheduleViewController() -> UIViewController
    func makeNotificationFeedViewController() -> UIViewController
    
    func makeAddScheduleViewController() -> UIViewController
    
    // 아이 탭
    func makeDailyJourneyViewController() -> UIViewController
    func makeCoinMissionViewController() -> UIViewController
    func makeWishWellViewController() -> UIViewController
}
