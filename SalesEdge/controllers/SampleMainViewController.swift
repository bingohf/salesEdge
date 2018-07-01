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

public protocol Form{
    func save()-> Bool
}


class SampleMainViewController :ButtonBarPagerTabStripViewController{
    let mySampleDAO = MySampleDAO()
    var sampleData = MySampleData(sampleId : "x")
    var vcMyList: MySampleListController? = nil
    var vcCustomer : SampleCustomerViewController? = nil
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vcMyList = storyboard.instantiateViewController(withIdentifier: "MySampleListController") as! MySampleListController
      
        vcCustomer = storyboard.instantiateViewController(withIdentifier: "SampleCustomerViewController") as! SampleCustomerViewController
        vcCustomer?.sampleData = sampleData
        vcCustomer?.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Customer", comment: "")))
        vcMyList?.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Show Room", comment: "")))
        return [vcCustomer!,vcMyList!]
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

    @IBAction func onSaveTouch(_ sender: Any) {
        if vcCustomer?.save() ?? false{
            mySampleDAO.create(data: sampleData)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
