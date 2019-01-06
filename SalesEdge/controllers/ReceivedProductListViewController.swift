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
import AlamofireImage


class ReceivedProductViewController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource {
    let refreshControl = UIRefreshControl()
    let receivedSampleDAO = ReceivedSampleDAO()
    var data = [ReceivedSampleData]()
    var disposeBag = DisposeBag()
    
    
    @IBOutlet weak var mTableView: UITableView!
    
    
    override func viewDidLoad() {
        refreshControl.addTarget(self, action:
            #selector(ReceivedProductViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        mTableView.refreshControl = refreshControl
        
        // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
        mTableView.rowHeight = UITableView.automaticDimension
        
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
        cell.mRedFlag.isHidden = true
        cell.badgeString = ""
        if let count = item.unread_count {
            if count > 0 {
                cell.badgeString = String(count)
            }
        }
        cell.mImage.af_setImage(
            withURL: URL(string: "\(AppCons.BASE_URL)\(item.graphicUrl ?? "")")!,
            placeholderImage: #imageLiteral(resourceName: "default_image"),
            imageTransition: .crossDissolve(0.2)
        )
//        let urlRequest = URLRequest(url: URL(string: "https://httpbin.org/image/jpeg")!)
//
//        imageDownloader.download(urlRequest) { response in
//            print(response.request)
//            print(response.response)
//            debugPrint(response.result)
//
//            if let image = response.result.value {
//                print(image)
//            }
//        }
//        if let prodno = item.firstProdNo {
//            let filePath = Helper.getImagePath(folder:"Received").appendingPathComponent("\(prodno)_type1.png")
//            do{
//                let fileManager = FileManager.default
//                if fileManager.fileExists(atPath: filePath.path){
//                    cell.mImage.image = UIImage(contentsOfFile: filePath.path)
//                }
//            }catch{
//                print(error)
//            }
//        }
        
       

        
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

        let params = [
            "device_id":deviceId
        ]
        self.mTableView.refreshControl?.beginRefreshing()
        Alamofire.request(AppCons.BASE_URL + "spJson/SP_GET_RECEIVEDLIST2", method: .get, parameters: params,encoding: URLEncoding.default)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                self.mTableView.refreshControl?.endRefreshing()
                self.view?.hideToastActivity()
                if let error = response.result.error {
                    var toastMessage = Helper.getErrorMessage(response.result)
                    if let message = String(data: response.data!, encoding: String.Encoding.utf8){
                        toastMessage = message
                    }
                    Helper.toast(message: toastMessage, thisVC: self)
                    return
                }
                do{
                    try self.receivedSampleDAO.remove()
                }catch{
                    print(error)
                }
                self.data.removeAll()
                let value = response.result.value
                let array = value as! NSArray
                let json = ""
                for object in array{
                    if let item = object as? NSDictionary{
                        if let unread_count = item.value(forKey: "unread_count") as? Int,
                            let dateStr = item.value(forKey: "updatedate") as? String{
                            let date = Helper.date(from:dateStr)
                            let dataFrom = item.value(forKey: "datafrom") as? String
                            let series = item.value(forKey: "series") as? String
                            let myTaxno = item.value(forKey: "myTaxNO") as? String
                            var url:String? = nil
                            let products = item.value(forKey: "products") as? NSArray
                            if let products = products{
                                for temp in products{
                                    if let productItem = temp as? NSDictionary{
                                        let prodNO = productItem.value(forKey: "ProdNO") as? String
                                        let graphicUrl = productItem.value(forKey: "graphicUrl") as? String
                                        let specdesc = productItem.value(forKey: "specdesc") as? String
                                        let updateDate = Helper.date(from:productItem.value(forKey: "updatedate") as? String)
                                        if url == nil {
                                            url = graphicUrl
                                        }
                                    }
                                }
                            }
                            let item = ReceivedSampleData(datetime: date!, products: Helper.converToJson(obj: products), title: dataFrom!,  sampleId: series!,  unread_count: unread_count, graphicUrl: url)
                            self.data.append(item)
                            self.receivedSampleDAO.create(productsData: [item])
                           
                        }
                        
                    }
                }
                self.data.sort(by: { (d1, d2) -> Bool in
                    return d1.datetime > d2.datetime
                })
                self.mTableView.reloadData()
                //self.loadProductImage(data: self.data)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_detail"{
            if let row = self.mTableView.indexPathForSelectedRow?.row{
                var item = data[row]
                item.unread_count = 0
                data[row] = item
                self.mTableView.reloadRows(at: [self.mTableView.indexPathForSelectedRow!], with: .automatic)
                let destinationVC = segue.destination as! ReceivedDetailController
                destinationVC.detailJson = item.products
                destinationVC.title = item.title
                destinationVC.sampleId = item.sampleId
            }
          
        }
    }
    
}
