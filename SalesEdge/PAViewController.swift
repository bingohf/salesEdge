//
//  SecondViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/1/20.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import UIKit
import WebKit

class PAViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var mWebView: UIWebView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pdaGuid = getPdaGuid().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            let myURL = URL(string: "http://ledwayazure.cloudapp.net/mobile?pdaGuid=\(pdaGuid)")
            let myRequest = URLRequest(url: myURL!)
            mWebView.loadRequest(myRequest)
        }
     
        mWebView.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getPdaGuid() -> String! {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString;
        let deviceName = UIDevice.current.modelName
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyyMMdd'T'HHmmss.S"
        let timeStamp = dformatter.string(from: Date.init())
        var language = Locale.preferredLanguages.first!
        var languageArr = language.components(separatedBy: "-")
        while languageArr.count > 2 {
            languageArr.remove(at: 1)
        }
        language = languageArr.joined(separator: "_")
        return "\(deviceId)-\(deviceName)-LEDWAY-\(timeStamp)~\(language)"
    }
}

