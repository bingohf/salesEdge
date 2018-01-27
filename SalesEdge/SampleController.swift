//
//  FirstViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/1/20.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SampleController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let controller = TabBaseViewController();
        let controller2 = TabBaseViewController();
        return [controller, controller2]
    }

    @IBAction func onMoreMenuTap(_ sender: Any) {
        let alertController = UIAlertController(title:"alert", message:"Select action",preferredStyle:UIAlertControllerStyle.actionSheet)
        let groupQRCodeAction = UIAlertAction(title:"Change Group", style:.default){
            (action: UIAlertAction!) -> Void in
            //print("按下確認後，閉包裡的動作")
        }
        alertController.addAction(groupQRCodeAction)
        alertController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        self.present(alertController, animated:true,completion:nil)
    }
}

