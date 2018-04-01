//
//  MyIDViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/1.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class MyIDViewController: XLPagerItemViewController{
    
    @IBOutlet weak var mImgQRCode: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString;
        let bizcard = UserDefaults.standard.string(forKey: "bizcard") ?? ""
        if let qrImage = Helper.generateQRCode(from:"\(deviceId)\r\n\(bizcard)"){
            mImgQRCode.image = qrImage
        }
    }
}
