//
//  ViewControllerFactory.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

public protocol ViewControllerFactory {
    // 부모 탭
    //func makeLoginViewController() -> UIViewController
    func makeParentOnboardingViewController() -> UIViewController
    func makeScheduleViewController() -> UIViewController
    func makeNotificationFeedViewController() -> UIViewController
    
    func makeAddScheduleViewController() -> UIViewController
    func makeMissionViewController() -> UIViewController
    func makeWriteMissionViewController() -> UIViewController
    func makeLoadingViewController() -> UIViewController
    func makeAIMissionViewController() -> UIViewController
    
    // 아이 탭
    func makeChildOnboardingViewController() -> UIViewController
    func makeDailyJourneyViewController() -> UIViewController
    func makeCoinMissionViewController() -> UIViewController
    func makeWishWellViewController() -> UIViewController
}
