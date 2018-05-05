//
//  MyBizCardViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/1.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class MyBizCardViewController:XLPagerItemViewController,UITextViewDelegate{
    
    @IBOutlet weak var mImgQRCode: UIImageView!
    
    @IBOutlet weak var mTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let preferences = UserDefaults.standard
        if let defaultText = preferences.string(forKey: "bizcard"){
            mTextView.text = defaultText
        }
        
        mTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        mTextView.layer.borderWidth = 1.0
        mTextView.layer.cornerRadius = 5
        mImgQRCode.image = nil
        
        textViewDidChange(mTextView)
    }
    
    func textViewDidChange(_ textView: UITextView){
        if let text = textView.text {
            
            if let qrcodeImage = Helper.generateQRCode(from:text){
                let scaleX = mImgQRCode.frame.size.width / qrcodeImage.extent.size.width
                let scaleY = mImgQRCode.frame.size.height / qrcodeImage.extent.size.height
                let scale = min(scaleX, scaleY)
                let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
                
                let image = UIImage(ciImage: transformedImage)
                mImgQRCode.image = image
                
                UIGraphicsBeginImageContext(CGSize(width:mImgQRCode.frame.size.width, height:mImgQRCode.frame.size.width))
                image.draw(in: CGRect(x:0, y:0, width:mImgQRCode.frame.size.width, height:mImgQRCode.frame.size.width))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                mImgQRCode.image = newImage
            }
             let preferences = UserDefaults.standard
            preferences.set(text, forKey: "bizcard")
            preferences.synchronize()
        }
    }
    
    @IBAction func onBtnDoneTouch(_ sender: Any) {
        mTextView.resignFirstResponder()
    }
    
    
}
