//
//  ImagesCoordinator.swift
//  PinterestClone
//
//  Created by SonHoang on 12/2/20.
//

import Foundation
import UIKit

class ImagesCoordinator: Coordinator {
    
    override func start() {
        let taskViewController = UIViewController()
        navigationController.viewControllers = [taskViewController]
    }
    
}
