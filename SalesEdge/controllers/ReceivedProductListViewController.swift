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
import RxSwift

class ReceivedProductViewController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource {
    let refreshControl = UIRefreshControl()
    let receivedSampleDAO = ReceivedSampleDAO()
    var data = [ReceivedSampleData]()
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var mTableView: UITableView!
    
    
    override func viewDidLoad() {
        refreshControl.addTarget(self, action:
            #selector(ReceivedProductViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        mTableView.refreshControl = refreshControl
        
        // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
        mTableView.rowHeight = UITableViewAutomaticDimension
        
        // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
        // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
        // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
        mTableView.estimatedRowHeight = 44.0 // set this to whatever your "average" cell height is; it doesn't need to be very accurate
        loadFromCache()
        loadRemote()

    
    }
    
    
    func loadFromCache(){
        Observable<[ReceivedSampleData]>.create { (observer ) -> Disposable in
            do{
                let samples = try self.receivedSampleDAO.findAll()
                observer.onNext(samples)
                observer.onCompleted()
            }catch {
                observer.onError(error)
            }
            return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: {
                if !(self.refreshControl.isRefreshing) {
                    self.refreshControl.beginRefreshing()
                }
            }, onDispose: {
                self.refreshControl.endRefreshing()
            })
            .subscribe(onNext: { [weak self] data in
                self?.data = data
                self?.mTableView.reloadData()
                if data.isEmpty{
                    self?.loadRemote()
                }
                }, onError: {
                    [weak self] error in
                    Helper.toast(message: error.localizedDescription, thisVC: self!)
                    
            }).disposed(by: disposeBag)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let item = data[indexPath.row]
        cell.mTxtLabel.text = item.title
        cell.mTxtTimestamp.text = Helper.format(date: item.datetime)
        cell.mImage.image = #imageLiteral(resourceName: "default_image")
        cell.mTxtSubTitle.text = ""
        cell.mRedFlag.isHidden = (item.unread_count ?? 0) < 1
        if let prodno = item.firstProdNo {
            let filePath = Helper.getImagePath(folder:"Received").appendingPathComponent("\(prodno)_type1.png")
            do{
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath.path){
                    cell.mImage.image = UIImage(contentsOfFile: filePath.path)
                }
            }catch{
                print(error)
            }
        }
        
       

        
        return cell
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadRemote()
        
    }
    
    func loadRemote(){
        Helper.loadUnReadCount(){

        }
        
        
        var deviceId = UIDevice.current.identifierForVendor!.uuidString
        if !Env.isProduction(){
            //deviceId = "42f7acf889d0db9"
        }
        do{
            try receivedSampleDAO.remove()
        }catch{
            print(error)
        }
        let params = [
            "device_id":deviceId
        ]
        self.mTableView.refreshControl?.beginRefreshing()
        Alamofire.request(AppCons.BASE_URL + "SPDataSet/SP_GET_RECEIVEDLIST", method: .post, parameters: params,encoding: JSONEncoding.default)
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
                self.data.removeAll()
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                for object in array{
                    if let item = object as? NSDictionary{
                        if let json = item.value(forKey: "json") as? String, let unread_count = item.value(forKey: "unread_count") as? Int{
                            if let dict = Helper.convertToDictionary(text: json) as? NSDictionary {
                                let datetime = Date(timeIntervalSince1970: TimeInterval((dict["update_date"] as! UInt64) / 1000))
                                var firstProdNo:String? = nil
                                if let prodLinks = dict["sampleProdLinks"] as? NSArray{
                                    if let firstItem = prodLinks.firstObject as? NSDictionary{
                                        firstProdNo = firstItem["prod_id"] as? String
                                    }
                                }
                                
                                let links = dict["sampleProdLinks"] as! NSArray
                                var myTaxNoLinks = [Any]()
                                for linkItem in links{
                                    let tempDict = NSMutableDictionary ()
                                    tempDict.addEntries(from: linkItem as! [AnyHashable : Any])
                                    let mytaxNo:String? = item["mytaxno"] as? String
                                    tempDict.addEntries(from: ["myTaxNo": mytaxNo])
                                    myTaxNoLinks.append(tempDict)
                                }
                                
                                let json = Helper.converToJson(obj:  myTaxNoLinks)
                                
                                let item = ReceivedSampleData(datetime: datetime, detailJson: json!, title: dict["dataFrom"] as! String, sampleId: dict["guid"] as! String, firstProdNo:firstProdNo, unread_count: unread_count)
                                self.data.append(item)
                                self.receivedSampleDAO.create(productsData: [item])
                            }
                        }
                        
                    }
                }
                self.data.sort(by: { (d1, d2) -> Bool in
                    return d1.datetime > d2.datetime
                })
                self.mTableView.reloadData()
                self.loadProductImage(data: self.data)
        }
    }
    
    func loadProductImage(data:[ReceivedSampleData])  {
        let imagePath = Helper.getImagePath(folder: "Received")
        for dataItem in data {
            if let links = Helper.convertToDictionary(text: dataItem.detailJson) as? NSArray {
                for arrayItem in links {
                    if let item = arrayItem as? NSDictionary{
                        let prodno = (item["prod_id"] as! String).replacingOccurrences(of: "'", with: "''")
                        var query = "prodno = '\(prodno)' "
                        if let mytaxno = item["myTaxNo"] as? String{
                            query = query + "and mytaxno='\(mytaxno)'"
                        }
                        
                        let params = ["query" : query]
                        Alamofire.request(AppCons.BASE_URL + "dataset/product", method: .get, parameters: params)
                            .debugLog()
                            .validate(statusCode: 200..<300)
                            .responseJSON{
                                response in
                                if let error = response.result.error {
                                    Helper.toast(message: Helper.getErrorMessage(response.result),thisVC: self)
                                    return
                                }
                                let value = response.result.value
                                let JSON = value as! NSDictionary
                                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                                if array.count < 1{
                                    Helper.toast(message: "No data",thisVC: self)
                                }
                                if let rItem = array.firstObject as? NSDictionary{
                                    if let graphic = rItem.value(forKey: "graphic") as? String {
                                        do{
                                            let data = Data(base64Encoded: graphic,options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                                            try data?.write(to: imagePath.appendingPathComponent("\(prodno)_type1.png", isDirectory: false))
                                            self.mTableView.reloadData()
                                        }catch{
                                            
                                        }
                                    }
                                }
                                
                        }
                        
                        
                    }
                }
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_detail"{
            if let row = self.mTableView.indexPathForSelectedRow?.row{
                var item = data[row]
                let destinationVC = segue.destination as! ReceivedDetailController
                destinationVC.detailJson = item.detailJson
                destinationVC.title = item.title
                destinationVC.sampleId = item.sampleId
            }
          
        }
    }
    
}
