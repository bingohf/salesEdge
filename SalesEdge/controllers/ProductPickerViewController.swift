//
//  ProductPickerViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/10.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class ProductPickerViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var mTableView: UITableView!
    override func viewDidLoad() {
        mTableView.setEditing(true, animated: true)
   
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        return cell
        
    }
    @IBAction func onCancelTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
