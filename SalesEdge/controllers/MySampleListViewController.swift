//
//  MySampleListViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/7/1.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MySampleListViewController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mTableView: UITableView?
    var disposeBag = DisposeBag()
    var data = [MySampleData]()
    let mySampleDAO = MySampleDAO()
    override func viewDidLoad() {
        loadDatas()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let  item = data[indexPath.row]
        cell.mTxtTimestamp.text = Helper.format(date: item.created as Date?)
        cell.mTxtLabel.text = item.customer
        if (cell.mTxtLabel.text ?? "") .isEmpty{
            cell.mTxtLabel.text = "NA"
        }
        cell.mTxtSubTitle.text = ""
        cell.mImage.image = #imageLiteral(resourceName: "default_image")
        cell.mRedFlag.layer.cornerRadius = 5
        cell.mRedFlag.isHidden = false
        if item.upload_date != nil {
            cell.mRedFlag.isHidden = item.upload_date?.timeIntervalSince1970 ?? 0 > item.created.timeIntervalSince1970
        }
        let filePath = Helper.getImagePath(folder:"Sample").appendingPathComponent("\(item.sampleId ?? "")_type1.png")
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
    

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Delete".localized()) { action, index in
            let rowData = self.data[index.row]
            do {
                self.mySampleDAO.remove(data: rowData)
                self.data.remove(at: index.row)
                tableView.deleteRows(at: [index], with: UITableView.RowAnimation.fade)
            } catch {
                print("delete failed: \(error)")
            }
            
        }
        share.backgroundColor = .orange
        return [share]
    }
    
    
    open func loadDatas()  {
        Observable<[MySampleData]>.create { (observer ) -> Disposable in
            do{
                let samples = try self.mySampleDAO.findAll()
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
//                if !(self.refreshControl.isRefreshing) {
//                    self.refreshControl.beginRefreshing()
//                }
            }, onDispose: {
                //self.refreshControl.endRefreshing()
            })
            .subscribe(onNext: { [weak self] data in
                self?.data = data
                self?.mTableView?.reloadData()
                }, onError: {
                    [weak self] error in
                    Helper.toast(message: error.localizedDescription, thisVC: self!)
                    
            }).disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_sample_detail"{
            let navigationVC = segue.destination as! UINavigationController
            let rootVC = navigationVC.viewControllers.first as! SampleMainViewController
            if let row = self.mTableView?.indexPathForSelectedRow?.row{
                rootVC.message = "Edit Sample"
                var item = data[row]
                rootVC.sampleData = item
                rootVC.onCompleted = {[weak self]sampleData in
                    self?.loadDatas()
                    
                }
            }
            
        }
    }

    
}
