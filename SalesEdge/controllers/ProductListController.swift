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

struct ViewDataItem {
    let label:String
    let subTitle:String
    let timeStamp:String
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
                        dataList.append(ViewDataItem(label: prodno, subTitle: desc, timeStamp: timestamp))
                        
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
    
}
