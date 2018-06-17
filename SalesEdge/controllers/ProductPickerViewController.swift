//
//  ProductPickerViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/10.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SQLite

protocol ProductPickDelegate {
    func getSelected() -> [ProductData]
    func callback(selected : [ProductData])
}

class ProductPickerViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    private var disposeBag = DisposeBag()
    private var data = [ProductData]()
    private var selected = [ProductData]()
    private let productDAO = ProductDAO()
    
    @IBOutlet weak var mTableView: UITableView!
    
    @IBOutlet weak var mTitleItem: UINavigationItem!
    @IBOutlet weak var mTitlebar: UINavigationBar!
    
    public var delegate:ProductPickDelegate? = nil
    override func viewDidLoad() {
        mTableView.setEditing(true, animated: true)
        mTableView.refreshControl = UIRefreshControl()
        
        mTableView.refreshControl?.addTarget(self, action:
            #selector(ProductPickerViewController.handleRefresh(_:)),
                                  for: UIControlEvents.valueChanged)
  
        selected = delegate?.getSelected() ?? [ProductData]()
        setSelectedCountTitle()
        reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    @IBAction func onSaveTouch(_ sender: Any) {
        delegate?.callback(selected: selected)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        print(indexPath)
        return indexPath
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        var isSelected = false
        for selectedItem in selected{
            if selectedItem.prodno == item.prodno{
                isSelected = true
            }
        }
        if isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let isSelected = mTableView.cellForRow(at: indexPath)?.isSelected ?? false
//        if isSelected{
//            mTableView.deselectRow(at: indexPath, animated: true)
//        }
        
        var found = false
        let item = data[indexPath.row]
        for selectedItem in selected{
            if selectedItem.prodno == item.prodno{
                found = true
            }
        }
        if !found {
            selected.append(item)
        }
        setSelectedCountTitle()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row < selected.count {
            selected.remove(at: indexPath.row)
        }
        setSelectedCountTitle()
    }
  
    func reloadData()  {
        Observable<[ProductData]>.create { (observer ) -> Disposable in
            do{
                let products = try self.productDAO.findAll()
                observer.onNext(products)
                observer.onCompleted()
            }catch {
                observer.onError(error)
            }
            return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] data in
                self?.data = data
                self?.mTableView.reloadData()
            }, onError: {  [weak self] (error) in
                if let vc = self {
                    Helper.toast(message: error.localizedDescription, thisVC: vc)
                }
            }, onSubscribed: {[weak self] in
               self?.mTableView.refreshControl?.beginRefreshing()
                
            }, onDispose: {[weak self] in
                self?.mTableView.refreshControl?.endRefreshing()
            }).subscribe()
            .disposed(by: disposeBag)
        
    }
    
    @IBAction func onCancelTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        reloadData()
    }
    
    func setSelectedCountTitle()  {
        self.title = "\(selected.count) product\(selected.count < 2 ? "":"s") selected"
        mTitleItem.title = self.title
    }
    
}
