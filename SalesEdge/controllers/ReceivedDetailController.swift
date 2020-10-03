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
    var create_date:Date?
   var spec:String
    var graphicUrl:String?
    
}

class ReceivedDetailController:UITableViewController{
    var products:[ReceivedProduct]? = nil
    var sampleId:String? = nil
    
    override func viewDidLoad() {
        let params = ["device_id":UIDevice.current.identifierForVendor!.uuidString,
                      "key2": sampleId!,
                      "type":"SAMPLE"]
        
        Alamofire.request(AppCons.SE_Server + "SpDataSet/SP_READ_MESSAGE", method: .post, parameters: params,encoding: JSONEncoding.default)
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
                            Helper.setBadge(count: count)
                        }
                    }
                }
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath) as! CustomTableCellView
        if let item = self.products?[indexPath.row]{
            cell.mTxtLabel.text = item.prod_no
            cell.mTxtSubTitle.text = item.spec
            cell.mTxtTimestamp.text = Helper.format(date: item.date)
            cell.mImage.image = #imageLiteral(resourceName: "default_image")
            if let image_url = item.image_url{
                cell.mImage.af_setImage(
                    withURL: URL(string: "\(AppCons.SE_Server)\(image_url)")!,
                    placeholderImage: #imageLiteral(resourceName: "default_image"),
                    imageTransition: .crossDissolve(0.2)
                )
            }

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let url = self.products?[indexPath.row].image_url{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "ImageViewController2") as! ImageViewController2
//            vc.imageUrl = url
//            vc.title = self.products?[indexPath.row].prod_no ?? ""
//            show(vc, sender: nil)
//        }
        if let url = self.products?[indexPath.row].image_url{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProductPictureController") as! ProductPictureController
            vc.prodno = self.products?[indexPath.row].prod_no ?? ""
            vc.mainUrl = url
            show(vc, sender: nil)
        }
    }
}
