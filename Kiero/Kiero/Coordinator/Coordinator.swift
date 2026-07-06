//
//  Coordinator.swift
//  Kiero
//
//  Created by 신혜연 on 7/4/26.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
