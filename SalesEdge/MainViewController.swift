//
//  MainViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/1.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UITabBarController,UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = UserDefaults.standard.integer(forKey: "selectedIndex")
        selectedIndex = index
        self.delegate = self
        
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController){
        let preference = UserDefaults.standard
        preference.set(selectedIndex, forKey: "selectedIndex")
        preference.synchronize()
    }
    
}
