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
    var vcMyList: MySampleListController? = nil

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vcMyList = storyboard.instantiateViewController(withIdentifier: "MySampleListController") as! MySampleListController
      
        let vc2 = storyboard.instantiateViewController(withIdentifier: "SampleCustomerViewController") as! SampleCustomerViewController
        vc2.sampleData = sampleData
        vc2.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Customer", comment: "")))
        vcMyList?.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Show Room", comment: "")))
        return [vcMyList!,vc2]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_pick"{
            let vc = segue.destination as! ProductPickerViewController
            vc.delegate = vcMyList
            
        }
    }

}
