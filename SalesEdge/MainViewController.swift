//
//  MainViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/1.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftEventBus

class MainViewController: UITabBarController,UITabBarControllerDelegate {
    
    @IBOutlet weak var mTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = UserDefaults.standard.integer(forKey: "selectedIndex")
        selectedIndex = index
        self.delegate = self
        
        checkStatus()
    }
    
    
    func checkStatus()  {
        let myTaxNo = Helper.getMyTaxNO()
        guard myTaxNo.count < 9 && myTaxNo.count > 0 else {
            return
        }
        let preferences = UserDefaults.standard
        let resigend = preferences.object(forKey: "resigend") as? String ?? "N"
        guard resigend != "Y" else {
            print("\(resigend):Skip check")
            return
        }
        
        let params = [
            "macno" :UIDevice.current.identifierForVendor!.uuidString,
            "MyTaxNo" : Helper.getMyTaxNO()
        ]
        Alamofire.request(AppCons.SE_Server + "SpJson/sp_check_status", method: .get, parameters: params,encoding: URLEncoding.default)
        .debugLog()
        .validate(statusCode: 200..<300)
        .responseJSON{
             response in
            if let error = response.result.error {
                Helper.toast(message: Helper.getErrorMessage(response.result), thisVC: self)
                return
            }
            let value = response.result.value
            let array = value as! NSArray
            if let resigned = (array.firstObject as? NSDictionary)?.value(forKey: "resigned") as? String, resigned == "Y" {
                preferences.removeObject(forKey: "myTaxNo")
                preferences.removeObject(forKey: "line")
                preferences.removeObject(forKey: "sm_server")
                preferences.removeObject(forKey: "sm_port")
                preferences.removeObject(forKey: "se_server")
                preferences.removeObject(forKey: "se_port")
                preferences.set("Y", forKey: "product")
                preferences.set("Y", forKey: "received")
                preferences.set("Y", forKey: "resigned")
                preferences.synchronize()
                AppCons.loadServer()
                AppCons.loadServer_Se()
                SwiftEventBus.post("GroupChange")
                Helper.toast(message: "You has been resigend", thisVC: self)
            }
            
            
            
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController){
        let preference = UserDefaults.standard
        preference.set(selectedIndex, forKey: "selectedIndex")
        preference.synchronize()
    }
    
}
