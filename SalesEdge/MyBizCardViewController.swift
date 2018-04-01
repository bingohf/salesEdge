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
            mImgQRCode.image = Helper.generateQRCode(from: text)
             let preferences = UserDefaults.standard
            preferences.set(text, forKey: "bizcard")
            preferences.synchronize()
        }
    }
    
    @IBAction func onBtnDoneTouch(_ sender: Any) {
        mTextView.resignFirstResponder()
    }
    
    
}
