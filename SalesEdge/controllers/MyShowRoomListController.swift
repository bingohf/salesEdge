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
    
    @IBOutlet weak var mTableView: UITableView?
    override func viewDidLoad() {
        data.removeAll()
        if let json = sampleData?.productJson{
            if let temp = Helper.convertToDictionary(text: json) as? NSArray {
                for object in temp{
                    if let item = object as? NSDictionary{
                        var updatedate:Date? = nil
                        if let intDate = item["create_date"] as? UInt64{
                            updatedate = Date(timeIntervalSince1970: TimeInterval(intDate / 1000))
                        }
                        let temp = ProductData(prodno: item["prod_id"] as! String, desc: item["spec_desc"] as? String, updatedate: updatedate)
                        data.append(temp)
                    }

                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let  item = data[indexPath.row]
        cell.mTxtTimestamp.text = Helper.format(date: item.updatedate)
        cell.mTxtLabel.text = item.prodno
        cell.mTxtSubTitle.text = item.desc
        cell.mImage.image = nil
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
            return ["prodno": product.prodno,
                    "desc": product.desc
            ]
        })
        sampleData?.productJson = Helper.converToJson(obj:temp)
        mTableView?.reloadData()
    }
    func getSelected() -> [ProductData] {
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
                Helper.toast(message: "No Image", thisVC: self)
            }
            
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let rowData = self.data[index.row]
            do {
                self.data.remove(at: index.row)
                tableView.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
            } catch {
                print("delete failed: \(error)")
            }
            
        }
        share.backgroundColor = .orange
        
        return [share]
    }
    
    func save() -> Bool {
        
        let temp =  data.map({ (product) -> NSDictionary in
            var jsonDate :Int? = nil
            if let date = product.updatedate{
                jsonDate = Int(((date.timeIntervalSince1970) * 1000.0).rounded())
            }
            return ["prod_id": product.prodno,
                    "spec_desc": product.desc ?? nil,
                    "create_date" : jsonDate ?? nil
            ]
        })
        sampleData?.productJson = Helper.converToJson(obj:temp)
        return true
    }
}
