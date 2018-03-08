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
        let myURL = URL(string: "https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        mWebView.loadRequest(myRequest)
        mWebView.delegate = self;
        self.view.makeToast("This is a piece of toast")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

