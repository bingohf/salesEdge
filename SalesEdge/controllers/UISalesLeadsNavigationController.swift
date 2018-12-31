//
//  UISalesLeadsNavigationController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/12/30.
//  Copyright © 2018 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus


class UISalesLeadsNavigationController:UINavigationController{
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarItem.badgeValue = UIApplication.shared.applicationIconBadgeNumber < 1 ? nil : String(UIApplication.shared.applicationIconBadgeNumber)
        SwiftEventBus.onMainThread(self, name: "BadgeValue") { result in
            if let count = result?.object as? Int{
                self.tabBarItem.badgeValue = nil
                if count > 0 {
                    self.tabBarItem.badgeValue = String(count)
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
}
