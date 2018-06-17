//
//  MySampleListController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/3.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MySampleListController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource, ProductPickDelegate {
    @IBOutlet weak var mTableView: UITableView!
    var disposeBag = DisposeBag()
    var data = [ProductData]()
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let  item = data[indexPath.row]
        cell.mTxtTimestamp.text = Helper.format(date: item.updatedate)
        cell.mTxtLabel.text = item.prodno
        cell.mTxtSubTitle.text = item.desc
        cell.mImage.image = nil
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = Helper.getImagePath(folder:"Show").appendingPathComponent("\(item.prodno)_type1.png")
        print(filePath)
        do{
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath.path){
                cell.mImage.image = UIImage(contentsOfFile: filePath.path)
            }
            
        }catch{
            print(error)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func callback(selected: [ProductData]) {
        data = selected
        mTableView.reloadData()
    }
    func getSelected() -> [ProductData] {
        return data
    }
}
