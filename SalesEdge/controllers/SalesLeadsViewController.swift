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
    
    @IBOutlet weak var mAddBarItem: UIBarButtonItem!
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc2 = storyboard.instantiateViewController(withIdentifier: "ReceivedProductViewController") as! ReceivedProductViewController
        vc2.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Received", comment: "")))
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "MySampleListController") as! MySampleListController
        vc1.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("My List", comment: "")))
        
        return [vc2,vc1]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add_sample"{
            self.moveToViewController(at: 0)
        }
    }
    
}


