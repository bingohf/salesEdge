//
//  ReceivedProductListViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/26.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Alamofire

class ReceivedProductViewController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource {
    let refreshControl = UIRefreshControl()
    let receivedSampleDAO = ReceivedSampleDAO()
    var data = [ReceivedSampleData]()
    @IBOutlet weak var mTableView: UITableView!
    override func viewDidLoad() {
        refreshControl.addTarget(self, action:
            #selector(ReceivedProductViewController.handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        mTableView.refreshControl = refreshControl
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        cell.mTxtLabel.text = data[indexPath.row].title
        cell.mTxtTimestamp.text = Helper.format(date: data[indexPath.row].datetime)
        return cell
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
       loadData()
        
    }
    
    func loadData(){
        let deviceId = "42f7acf889d0db9"
        let query = "isnull(json,'') <>'' and shareToDeviceId like  '%\(deviceId)%'"
        let orderBy = " order by UPDATEDATE desc"
        let params = [
            "query": query,
            "orderBy": orderBy
        ];
        do{
            try receivedSampleDAO.remove()
        }catch{
            print(error)
        }
        
        Alamofire.request(AppCons.BASE_URL + "dataset/PRODUCTAPPGET", method: .get, parameters: params)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                self.mTableView.refreshControl?.endRefreshing()
                self.view?.hideToastActivity()
                if let error = response.result.error {
                    Helper.toast(message: Helper.getErrorMessage(response.result), thisVC: self)
                    return
                }
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                for object in array{
                    if let item = object as? NSDictionary{
                        if let json = item.value(forKey: "json") as? String{
                            if let dict = Helper.convertToDictionary(text: json){
                                let datetime = Date(timeIntervalSince1970: TimeInterval((dict["create_date"] as! UInt64) / 1000))
                                let json = Helper.converToJson(obj:  dict["sampleProdLinks"] )
                                let item = ReceivedSampleData(datetime: datetime, detailJson: json!, title: dict["dataFrom"] as! String)
                                self.data.append(item)
                            }
                        }
                        
                    }
                }
                self.mTableView.reloadData()
        }
    }
    
}
