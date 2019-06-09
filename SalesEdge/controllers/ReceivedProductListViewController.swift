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
import CoreStore

class ReceivedProductViewController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource {
    let refreshControl = UIRefreshControl()
    let receivedSampleDAO = ReceivedSampleDAO()
    var data = [ReceivedSample]()
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
       let samples = CoreStore.fetchAll(From<ReceivedSample>().orderBy(.descending(\.date)))
        self.data = samples ?? []
        mTableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let item = data[indexPath.row]
        cell.mTxtLabel.text = item.from
        cell.mTxtTimestamp.text = Helper.format(date: item.date)
        cell.mImage.image = #imageLiteral(resourceName: "default_image")
        cell.mTxtSubTitle.text = ""
        cell.mRedFlag.isHidden = true
        cell.badgeString = ""
        if let count = item.unread_count?.intValue {
            if count > 0 {
                cell.badgeString = String(count)
            }
        }
        
        
        for product in item.products ?? []{
            if let imageUrl  = product.image_url{
                cell.mImage.af_setImage(
                    withURL: URL(string: "\(AppCons.SE_Server)\(imageUrl)")!,
                    placeholderImage: #imageLiteral(resourceName: "default_image"),
                    imageTransition: .crossDissolve(0.2)
                )
                break
            }
        }


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
        Alamofire.request(AppCons.SE_Server + "spJson/SP_GET_RECEIVEDLIST2", method: .get, parameters: params,encoding: URLEncoding.default)
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
                    try CoreStore.perform(synchronous: { (transaction) -> Int? in
                        transaction.deleteAll(From<ReceivedSample>())
                    })

                self.data.removeAll()
                let value = response.result.value
                let array = value as! NSArray
                let transaction = CoreStore.beginUnsafe()
          
          
                for object in array{
                    if let item = object as? NSDictionary{
                        if let unread_count = item.value(forKey: "unread_count") as? Int,
                            let dateStr = item.value(forKey: "updatedate") as? String{
                            let receivedSample = transaction.create(Into<ReceivedSample>())
                            receivedSample.date = Helper.date(from:dateStr)
                            receivedSample.from = item.value(forKey: "datafrom") as? String
                            receivedSample.sample_id = item.value(forKey: "series") as? String
                            receivedSample.products = Set<ReceivedProduct>()
                            let products = item.value(forKey: "products") as? NSArray
                            if let products = products{
                                for temp in products{
                                    if let productItem = temp as? NSDictionary{
                                        let receivedProduct = transaction.create(Into<ReceivedProduct>())
                                        receivedProduct.sample = receivedSample
                                        receivedSample.products?.insert(receivedProduct)
                                        let prodNO = productItem.value(forKey: "ProdNO") as? String
                                        let graphicUrl = productItem.value(forKey: "graphicUrl") as? String
                                        let specdesc = productItem.value(forKey: "specdesc") as? String
                                        let updateDate = Helper.date(from:productItem.value(forKey: "updatedate") as? String)
                                        receivedProduct.prod_no = prodNO
                                        receivedProduct.image_url = graphicUrl
                                        receivedProduct.spec = specdesc
                                        receivedProduct.date = updateDate
                                    }
                                }
                            }
                           // self.data.append(receivedSample)
                           
                        }
                        
                    }
                }
                self.data.sort(by: { (d1, d2) -> Bool in
                    if let date1 = d1.date{
                        if let date2 = d2.date{
                            return date1 > date2
                        }
                    }
                    return false
                })
                try transaction.commitAndWait()
                    self.loadFromCache()
                }catch{
                    print(error)
                }
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
                destinationVC.products = Array(item.products ?? [])
                destinationVC.title = item.from
                destinationVC.sampleId = item.sample_id
            }
          
        }
    }
    
}
