//
//  MyShowRoomListController
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/3.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MyShowRoomListController:XLPagerItemViewController,UITableViewDelegate, UITableViewDataSource, ProductPickDelegate ,Form{
    var disposeBag = DisposeBag()
    var data = [ProductData]()
    var sampleData:MySampleData? = nil
    let defaultImage = #imageLiteral(resourceName: "default_image")
     private let productDAO = ProductDAO()
    @IBOutlet weak var mTableView: UITableView?
    override func viewDidLoad() {
        loadJsonData()

    }
    
    open func loadJsonData()   {
        data.removeAll()
        if let json = sampleData?.productJson{
            if let temp = Helper.convertToDictionary(text: json) as? NSArray {
                for object in temp{
                    if let item = object as? NSDictionary{
                        var updatedate:Date? = nil
                        if let intDate = item["create_date"] as? UInt64{
                            updatedate = Date(timeIntervalSince1970: TimeInterval(intDate / 1000))
                        }
                        if let prodno = item["prod_id"]{
                            let temp = ProductData(prodno: prodno as! String, desc: item["spec_desc"] as? String, updatedate: updatedate)
                            data.append(temp)
                        }
                    }
                    
                }
            }
        }
        mTableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let  item = data[indexPath.row]
        cell.mTxtTimestamp.text = Helper.format(date: item.updatedate)
        cell.mTxtLabel.text = item.prodno
        cell.mTxtSubTitle.text = item.desc
        cell.mImage.image = defaultImage
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func callback(selected: [ProductData]) {
        data = selected
        let temp =  data.map({ (product) -> NSDictionary in
            var jsonDate :Int64? = nil
            if let date = product.updatedate{
                jsonDate = Int64(((date.timeIntervalSince1970) * 1000.0).rounded())
            }
            return ["prod_id": product.prodno,
                    "spec_desc": product.desc,
                "create_date":jsonDate
            ]
        })
        sampleData?.productJson = Helper.converToJson(obj:temp)
        sampleData?.isDirty = true
        mTableView?.reloadData()
    }
    func getSelected() -> [ProductData] {
        loadJsonData()
        return data
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            let  item = data[indexPath.row]
            let filePath = Helper.getImagePath(folder:"Show").appendingPathComponent("\(item.prodno)_type1.png")
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath.path){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                vc.imageUrl = filePath
                show(vc, sender: nil)
            }else{
                Helper.toast(message: "No Image".localized(), thisVC: self)
            }
            
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Delete".localized()) { action, index in
            let rowData = self.data[index.row]
            do {
                self.data.remove(at: index.row)
                tableView.deleteRows(at: [index], with: UITableView.RowAnimation.fade)
            } catch {
                print("delete failed: \(error)")
            }
            
        }
        share.backgroundColor = .orange
        
        return [share]
    }
    
    func save() -> Bool {
        
        let temp =  data.map({ (product) -> NSDictionary in
            var jsonDate :Int64? = nil
            if let date = product.updatedate{
                jsonDate = Int64(((date.timeIntervalSince1970) * 1000.0).rounded())
            }
            return ["prod_id": product.prodno,
                    "spec_desc": product.desc ?? nil,
                    "create_date" : jsonDate ?? nil
            ]
        })
        sampleData?.productJson = Helper.converToJson(obj:temp)
        return true
    }
    
    func addProduct(qrcode:String){
        loadJsonData()
        let found = data.filter { (product) -> Bool in
            return product.prodno == qrcode
        }
        if found.count == 0{
            do{
                if let product = try productDAO.findBy(prodno: qrcode){
                    self.data.append(product)
                    save()
                    mTableView?.reloadData()
                }else{
                    Helper.toast(message: "Can not find the product( \(qrcode))", thisVC: self)
                }
            }catch{
                print(error)
            }
        }
        sampleData?.isDirty = true
    
    }
}
