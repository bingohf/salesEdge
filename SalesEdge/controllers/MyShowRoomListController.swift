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
    var onPcsNumChange:((_ value:Int, _ cell: CustomTableCellView) -> Void)? = nil
    var onMemoBtnTouch:((_ index:Int) -> Void)? = nil
    override func viewDidLoad() {
        loadJsonData()
        onPcsNumChange = {[weak self](value, cell) in
            var prodInfo = self?.data[cell.index]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "num_unit_picker_controller") as! NumUnitPickerController
            
            let alert = UIAlertController(style: .alert, title: "Selections")
            alert.set(vc: vc, height: 300)
            //alert.show()
            let okAction = UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("OK")
                //self?.data[cell.index].pcsnum = value
                let (state_type, pcsnum, unit) = vc.getValues()
                self?.data[cell.index].stateType = state_type
                self?.data[cell.index].pcsnum = Int(pcsnum)!
                self?.data[cell.index].unit = unit
                cell.mTxtPcsNum.text = "\(state_type) \(pcsnum) \(unit)"
                self?.sampleData?.isDirty = true
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: false, completion: {
                
            })
            
            vc.setValues(stateType: prodInfo!.stateType, pcsnum: prodInfo!.pcsnum, unit: prodInfo!.unit)
            
       }
        onMemoBtnTouch = {[weak self](index) in
            let alert = UIAlertController(title: "Memo".localized(), message: nil, preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.placeholder = "Memo".localized()
            }
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \(textField?.text)")
                if let prodno = textField?.text {
                    if !prodno.isEmpty {
                        self?.sampleData?.isDirty = true
                        self?.data[index].memo = textField?.text
                        self?.mTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                    
                }
                
                
            }))
            alert.addAction(UIAlertAction(title: "Scan QRCode".localized(), style: .default, handler: { (_) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "QRCodeScannerViewController") as! QRCodeScannerViewController
                destinationVC.onCompleted = {[weak self](qrcode)in
                    self?.data[index].memo = qrcode
                    self?.mTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    
                }
                self?.present(destinationVC, animated: true, completion: nil)
                
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (_) in
                
            }))
            
            // 4. Present the alert.
            self?.present(alert, animated: true, completion: nil)
       }
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
                            let temp = ProductData(prodno: prodno as! String, desc: item["spec_desc"] as? String, updatedate: updatedate, pcsnum: (item["pcsnum"] as? Int) ?? 1, stateType: item["state_type"] as? String ?? "Hanger", unit:item["unit"] as? String ?? "PCS", memo: item["memo"] as? String)
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
        cell.index = indexPath.row
        cell.onPcsChange = onPcsNumChange
        cell.onMemoBtnCallback = onMemoBtnTouch
        let  item = data[indexPath.row]
        cell.mTxtTimestamp?.text = Helper.format(date: item.updatedate)
        cell.mTxtLabel.text = item.prodno
        cell.mTxtSubTitle.text = item.desc
        cell.mImage.image = defaultImage
        cell.mTxtMemo.text = item.memo
        if (item.memo ?? "").isEmpty{
            cell.mTxtMemo.text = "Click to set memo"
        }
        cell.mTxtPcsNum.text = "\(item.stateType) \(item.pcsnum ?? 0) \(item.unit)"
        let filePath = Helper.getImagePath(folder:"Show").appendingPathComponent("\(item.prodno)_type1.png")
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
        sampleData?.productJson = dataToJson()
        sampleData?.isDirty = true
        mTableView?.reloadData()
    }
    func getSelected() -> [ProductData] {
        loadJsonData()
        return data
    }
    
    func dataToJson() -> String? {
        let temp =  data.map({ (product) -> NSDictionary in
            var jsonDate :Int64? = nil
            if let date = product.updatedate{
                jsonDate = Int64(((date.timeIntervalSince1970) * 1000.0).rounded())
            }
            return ["prod_id": product.prodno,
                    "spec_desc": product.desc,
                "create_date":jsonDate,
                "pcsnum":product.pcsnum,
                "state_type":product.stateType,
                "unit": product.unit,
                "memo":product.memo
            ]
        })
        return Helper.converToJson(obj:temp)
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
                self.sampleData?.productJson = self.dataToJson()
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
                    "create_date" : jsonDate ?? nil,
                    "pcsnum": product.pcsnum,
                    "state_type": product.stateType,
                    "unit" :product.unit,
                    "memo": product.memo
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
