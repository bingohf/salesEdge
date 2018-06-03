//
//  MyPageViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/3/31.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import XLPagerTabStrip



class MyPageViewController :ButtonBarPagerTabStripViewController{

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyboard.instantiateViewController(withIdentifier: "MyShareAppViewController") as! XLPagerItemViewController
        shareVC.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("App", comment: "")))
        let myIdVC = storyboard.instantiateViewController(withIdentifier: "MyIDViewController") as! MyIDViewController
        myIdVC.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("MyID", comment: "")))
        
        let myVC = storyboard.instantiateViewController(withIdentifier: "MyBizCardViewController") as! MyBizCardViewController
        myVC.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("My", comment: "")))
        
        return [shareVC,myVC, myIdVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
    }
}


