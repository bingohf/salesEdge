//
//  SalesLeadsViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/26.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//


import Foundation
import XLPagerTabStrip



class SalesLeadsViewController :ButtonBarPagerTabStripViewController{
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReceivedProductViewController") as! ReceivedProductViewController
        vc.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Received", comment: "")))
        
        return [vc]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
    }
}



