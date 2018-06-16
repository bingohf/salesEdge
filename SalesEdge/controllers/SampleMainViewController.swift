//
//  SampleMainViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/9.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import UIKit


class SampleMainViewController :ButtonBarPagerTabStripViewController{
    var sampleData:SampleData? = SampleData(sampleId: "x")
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc2 = storyboard.instantiateViewController(withIdentifier: "SampleCustomerViewController") as! SampleCustomerViewController
        vc2.sampleData = sampleData
        vc2.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Customer", comment: "")))
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "MySampleListController") as! MySampleListController
        vc1.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Show Room", comment: "")))
        
        return [vc1,vc2]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        containerView.contentSize = containerView.frame.size
    }
    
    @IBAction func onCancelTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
