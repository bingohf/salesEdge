//
//  ProductListController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/15.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SQLite
import Alamofire

struct ViewDataItem {
    let label:String
    let subTitle:String
    let timeStamp:String
    let key:String
}

class ProductListController : UITableViewController{
    
    var disposeBag = DisposeBag()
    var data = [ViewDataItem]()
    
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action:
            #selector(ProductListController.handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(self.refreshControl!)
        reloadData()
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let  item = data[indexPath.row]
        cell.mTxtTimestamp.text = item.timeStamp
        return cell
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        reloadData()
    }
    
    func toast(message:String) {
        var vc:UIViewController? = self
        while ((vc?.parent) != nil)  {
            vc = vc?.parent
        }
        if let vc = vc {
            vc.view.makeToast(message)
        }
    }
    
    
    
    func reloadData()  {
        Observable<[ViewDataItem]>.create { (observer ) -> Disposable in
            
            do{
                var dataList = [ViewDataItem]()
                let product = LDataBase.shared.product
                if let db = LDataBase.shared.db {
                    for row in try db.prepare(product.table) {
                        let prodno =  row[product.prodno]
                        let desc = row[product.desc]
                        let timestamp = Helper.format(date: row[product.create_date])
                        dataList.append(ViewDataItem(label: prodno, subTitle: desc, timeStamp: timestamp, key:prodno))
                        
                        // id: 1, email: alice@mac.com, name: Optional("Alice")
                    }
                }
                observer.onNext(dataList)
                observer.onCompleted()
            }catch {
                observer.onError(error)
            }
            return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: {
                if !(self.refreshControl?.isRefreshing)! {
                    self.refreshControl?.beginRefreshing()
                }
            }, onDispose: {
                self.refreshControl?.endRefreshing()
            })
            .subscribe(onNext: { [weak self] data in
                self?.data = data
                self?.tableView.reloadData()
                }, onError: { (error) in
                    self.toast(message:"error: \(error)")
            }).disposed(by: disposeBag)
    }
    


    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let rowData = self.data[index.row]
            let product = LDataBase.shared.product
           let thisRow = product.table.filter(product.prodno == rowData.key)
            do {
                if let db = LDataBase.shared.db {
                    if try db.run(thisRow.delete()) > 0 {
                        print("deleted alice")
                        self.data.remove(at: index.row)
                        tableView.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
                    } else {
                        print("alice not found")
                    }
                }
            } catch {
                print("delete failed: \(error)")
            }
            
        }
        share.backgroundColor = .orange
        
        return [share]
    }

    @IBAction func onMoreClick(_ sender: Any) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Download sample group", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.downloadGroupShow()
        })
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func downloadGroupShow() {
        view?.makeToastActivity(.center)
        let sql = "select * from view_GroupShowName "
        let escapeSql = sql.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        Alamofire.request(AppCons.BASE_URL + "sql/\(escapeSql)", method: .get, parameters: nil, encoding: JSONEncoding.default)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                self.view?.hideToastActivity()
                if let error = response.result.error {
                    self.toast(message: Helper.getErrorMessage(response.result))
                    return
                }
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                let optionMenu = UIAlertController(title: nil, message: "Choose exhibition", preferredStyle: .actionSheet)
                for object in array{
                    if let item = object as? NSDictionary{
                        if let name = item.value(forKey: "showname"){
                            let action = UIAlertAction(title: name as! String, style: .default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                self.download(showName:name as! String)
                            })
                            optionMenu.addAction(action)
                        }

                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("Cancelled")
                })
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
                
        }
    }
    
    func download(showName:String)  {
        let preferences = UserDefaults.standard
        let mytaxno = preferences.object(forKey: "myTaxNo") ?? ""
        let sql = "select * from view_GroupShowList where showname ='\(showName)'"
        let escapeSql = sql.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        Alamofire.request(AppCons.BASE_URL + "sql/\(escapeSql)", method: .get, parameters: nil, encoding: JSONEncoding.default)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                self.view?.hideToastActivity()
                
                if let error = response.result.error {
                    self.toast(message: Helper.getErrorMessage(response.result))
                    return
                }
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                for object in array{
                    if let item = object as? NSDictionary{
                        if let prodno = item.value(forKey: "prodno") as? String   {

                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let dataPath = documentsDirectory.appendingPathComponent("Show")
                            
                            do {
                                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                            } catch let error as NSError {
                                print("Error creating directory: \(error.localizedDescription)")
                            }
                           
                            do {
                                if let graphic = item.value(forKey: "graphic") as? String {
                                    let data = Data(base64Encoded: graphic,options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                                    try data?.write(to: dataPath.appendingPathComponent("\(prodno)_type1.png", isDirectory: false))
                                }
                                if let graphic = item.value(forKey: "graphic2") as? String {
                                    let data = Data(base64Encoded: graphic,options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                                    try data?.write(to: dataPath.appendingPathComponent("\(prodno)_type2.png", isDirectory: false))
                                }
                            } catch let error as NSError {
                                print("Error creating directory: \(error.localizedDescription)")
                            }
                           
                        }
                        
                    }
                }

                
        }
    }
}
