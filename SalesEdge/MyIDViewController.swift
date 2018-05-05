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
        if let qrcodeImage = Helper.generateQRCode(from:"\(deviceId)\r\n\(bizcard)"){
            let scaleX = mImgQRCode.frame.size.width / qrcodeImage.extent.size.width
            let scaleY = mImgQRCode.frame.size.height / qrcodeImage.extent.size.height
            let scale = min(scaleX, scaleY)
            let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX:scale, y:scale))
           // let transformedImage1 = qrcodeImage.transformed(by: CGAffineTransformMakeScale(scaleX, scaleY))

            let image = UIImage(ciImage: transformedImage)
            mImgQRCode.image = image
            
            UIGraphicsBeginImageContext(CGSize(width:mImgQRCode.frame.size.width, height:mImgQRCode.frame.size.width))
            image.draw(in: CGRect(x:0, y:0, width:mImgQRCode.frame.size.width, height:mImgQRCode.frame.size.width))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            mImgQRCode.image = newImage
            
        }
    }
}
