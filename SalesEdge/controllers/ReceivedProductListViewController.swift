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
        loadFromCache()
        
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
        cell.mTxtLabel.text = data[indexPath.row].title
        cell.mTxtTimestamp.text = Helper.format(date: data[indexPath.row].datetime)
        return cell
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadRemote()
        
    }
    
    func loadRemote(){
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
        self.mTableView.refreshControl?.beginRefreshing()
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
                                let datetime = Date(timeIntervalSince1970: TimeInterval((dict["update_date"] as! UInt64) / 1000))
                                var firstProdNo:String? = nil
                                if let prodLinks = dict["sampleProdLinks"] as? NSArray{
                                    if let firstItem = prodLinks.firstObject as? NSDictionary{
                                        firstProdNo = firstItem["prod_id"] as? String
                                    }
                                }
                                let json = Helper.converToJson(obj:  dict["sampleProdLinks"]! )
                                
                                let item = ReceivedSampleData(datetime: datetime, detailJson: json!, title: dict["dataFrom"] as! String, sampleId: dict["guid"] as! String, firstProdNo:firstProdNo)
                                self.data.append(item)
                                self.receivedSampleDAO.create(productsData: [item])
                            }
                        }
                        
                    }
                }
                self.data.sort(by: { (d1, d2) -> Bool in
                    return d1.datetime < d2.datetime
                })
                self.mTableView.reloadData()
                self.loadProductImage(data: self.data)
        }
    }
    
    func loadProductImage(data:[ReceivedSampleData])  {
        for dataItem in data {
           
        }
        
    }
    
    
}
