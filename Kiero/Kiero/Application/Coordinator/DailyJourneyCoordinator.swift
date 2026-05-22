//
//  DailyJourneyCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import UIKit

final class DailyJourneyCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    
    init(
        navigationController: UINavigationController,
        factory: ViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() -> UIViewController {
        let vc = factory.makeDailyJourneyViewController()
        
        vc.onMapTap = { [weak self] in
            self?.showMap()
        }
        
        vc.onGiveFireStone = { [weak self] count in
            self?.showGiveFireStone(count: count)
        }
        
        vc.onMissionComplete = { [weak self] image, stoneType, scheduleDetailId in
            self?.showMissionComplete(
                image: image,
                stoneType: stoneType,
                scheduleDetailId: scheduleDetailId
            )
        }
        
        return vc
    }
    
    private func showMap() {
        let vc = factory.makeDailyJourneyMapViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showGiveFireStone(count: Int) {
        let vc = factory.makeGiveFireStoneViewController(
            count: count
        )
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showMissionComplete(
        image: UIImage,
        stoneType: StoneType?,
        scheduleDetailId: Int?
    ) {
        let vc = factory.makeMissionCompleteViewController(
            image: image,
            stoneType: stoneType,
            scheduleDetailId: scheduleDetailId
        )
        
        navigationController.pushViewController(vc, animated: true)
    }
}
