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



class ProductListController : UITableViewController, ProductDelegate{
    let DEFAULT_GROUP = "3036A"
    
    var disposeBag = DisposeBag()
    var data = [ProductData]()
    let productDAO = ProductDAO()
    
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
            do {
                try self.productDAO.remove(productData: rowData)
                self.data.remove(at: index.row)
                tableView.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
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
            self.downloadGroupShow(sender)
        })
    
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        // 5
        self.present(optionMenu, animated: true){
            optionMenu.view.superview?.isUserInteractionEnabled = true
            optionMenu.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    @objc func alertControllerBackgroundTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    func downloadGroupShow(_ sender: Any) {
        view?.makeToastActivity(.center)
        let preferences = UserDefaults.standard
        let mytaxno = preferences.object(forKey: "myTaxNo") ?? DEFAULT_GROUP
        let sql = "select * from view_GroupShowName where mytaxno ='\(mytaxno)'"
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
                optionMenu.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                // 5
                self.present(optionMenu, animated: true){
                    optionMenu.view.superview?.isUserInteractionEnabled = true
                    optionMenu.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
                }
                
                
                
        }
    }
    
    func download(showName:String)  {
        let preferences = UserDefaults.standard
        let mytaxno = preferences.object(forKey: "myTaxNo") ?? DEFAULT_GROUP
        let sql = "select * from view_GroupShowList where showname ='\(showName)' and mytaxno ='\(mytaxno)'"
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
                if array.count < 1{
                    self.toast(message: "No data")
                }
                for object in array{
                    var productsData = [ProductData]()
                    if let item = object as? NSDictionary{
                        if let prodno = item.value(forKey: "prodno") as? String   {
                            let dataPath = Helper.getImagePath(folder: "Show")
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
                           
                            var date = Date()
                            if let dateStr = item.value(forKey: "updatedate") as? String{
                                date = dateStr.dateFromISO8601 ?? Date()
                            }
                            let spec:String? = item.value(forKey: "specdesc") as? String
                            let product = ProductData(prodno: prodno, desc: spec, updatedate: date)
                            productsData.append(product)
                            
                        }
                        
                    }
                    self.productDAO.create(productsData: productsData)
                }
                self.reloadData()

                
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_product_detail" {
            let destinationVC = segue.destination as? ProductViewController
            if let row = self.tableView.indexPathForSelectedRow?.row{
                var item = data[row]
                destinationVC?.title = item.prodno
                destinationVC?.productData = item
                destinationVC?.delegate = self
            }
        }
        
    }

    
    func onDataChange(productData: ProductData) {
        if let index = data.index(where: {$0.prodno == productData.prodno}) {
            if index > -1 {
                data[index] = productData
            }
        } else{
             data.append(productData)
        }
       
        tableView.reloadData()
    }
    
    @IBAction func onAddTouch(_ sender: Any) {
        
        let alert = UIAlertController(title: "Input", message: nil, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Product No."
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            if let prodno = textField?.text {
                if !prodno.isEmpty {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "ProductDetail") as! ProductViewController
                    destinationVC.productData = ProductData(prodno: prodno, desc: "", updatedate: Date())
                    destinationVC.title = prodno
                    destinationVC.delegate = self
                    self.show(destinationVC, sender: sender)
                }
                
            }
          
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
}
