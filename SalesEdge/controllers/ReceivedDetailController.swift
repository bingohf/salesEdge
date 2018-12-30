//
//  ReceivedDetailController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/2.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct ProdInfo {
   var prodno:String
    var create_date:Date
   var spec:String
    
}

class ReceivedDetailController:UITableViewController{
    var detailJson:String? = nil
    var sampleId:String? = nil
    var data = [ProdInfo]()
    
    override func viewDidLoad() {
        let params = ["device_id":UIDevice.current.identifierForVendor!.uuidString,
                      "key2": sampleId!,
                      "type":"SAMPLE"]
        
        Alamofire.request(AppCons.BASE_URL + "SpDataSet/SP_READ_MESSAGE", method: .post, parameters: params,encoding: JSONEncoding.default)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                if let error = response.result.error {
                    return
                }
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                for object in array{
                    if let item = object as? NSDictionary{
                        if let count = item.value(forKey: "count") as? Int{
                            UIApplication.shared.applicationIconBadgeNumber = count
                        }
                    }
                }
        }
        
        if let array = Helper.convertToDictionary(text: detailJson!) as? NSArray {
            for case let item as NSDictionary in array{
                let prodno = item.value(forKey: "prod_id") as! String
                let spec = item.value(forKey: "spec_desc") as? String ?? ""
                let date = Date(timeIntervalSince1970: TimeInterval((item["create_date"] as! UInt64) / 1000))
                data.append(ProdInfo(prodno: prodno, create_date: date, spec: spec))
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        let item = data[indexPath.row]
        cell.mTxtLabel.text = item.prodno
        cell.mTxtSubTitle.text = item.spec
        cell.mTxtTimestamp.text = Helper.format(date: item.create_date)
        

            let filePath = Helper.getImagePath(folder:"Received").appendingPathComponent("\(item.prodno)_type1.png")
            do{
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath.path){
                    cell.mImage.image = UIImage(contentsOfFile: filePath.path)
                }else{
                    cell.mImage.image = #imageLiteral(resourceName: "default_image")
                }
            }catch{
                print(error)
            }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prodno = data[indexPath.row].prodno
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("Received").appendingPathComponent("\(prodno)_type1.png")
        do{
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
}
