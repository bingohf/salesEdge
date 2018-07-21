//
//  SampleMainViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/9.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import UIKit
import Alamofire
import RxSwift
import RxAlamofire

public protocol Form{
    func save()-> Bool
}


class SampleMainViewController :ButtonBarPagerTabStripViewController{
    let mySampleDAO = MySampleDAO()
    var sampleData = MySampleData(sampleId : Helper.pdaGuid())
    open var vcMyList: MyShowRoomListController? = nil
    var vcCustomer : SampleCustomerViewController? = nil
    var onCompleted :((MySampleData?) -> Void)?
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vcMyList = storyboard.instantiateViewController(withIdentifier: "MyShowRoomListController") as! MyShowRoomListController
      
        vcCustomer = storyboard.instantiateViewController(withIdentifier: "SampleCustomerViewController") as! SampleCustomerViewController
        vcCustomer?.sampleData = sampleData
        vcCustomer?.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Customer", comment: "")))
        vcMyList?.setInfo(itemInfo: IndicatorInfo(title: NSLocalizedString("Show Room", comment: "")))
        vcMyList?.sampleData = sampleData
        return [vcCustomer!,vcMyList!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        containerView.contentSize = containerView.frame.size
    }
    
    @IBAction func onCancelTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_pick"{
            let vc = segue.destination as! ProductPickerViewController
            vc.delegate = vcMyList
            
        }
    }

    @IBAction func onSaveTouch(_ sender: Any) {
        if vcCustomer?.save() ?? false && vcMyList?.save() ?? false{
            var params = Helper.makeRequest()
            params.merge(["series": sampleData.sampleId ?? "",
                          "custMemo" : sampleData.customer ?? "",
                          "shareToDeviceId": sampleData.shareToDeviceID ?? "",
                          "empno": UIDevice.current.identifierForVendor!.uuidString,
                          "json" : toJson(sampleData: sampleData)
            ]) { (any1, any2) -> Any in
                any2
            }
            let imagePath = Helper.getImagePath(folder: "Sample").appendingPathComponent("\(sampleData.sampleId ?? "xxxxxx")_type1.png")
            if FileManager.default.fileExists(atPath: imagePath.path){
                if let imageData1 = NSData(contentsOf: imagePath){
                    let strBase641 = imageData1.base64EncodedString(options: .lineLength64Characters)
                    params.merge(["custCardPic": strBase641
                    ]) { (any1, any2) -> Any in
                        any2
                    }
                }
            }
            let manager = SessionManager.default
            var ob = manager.rx.request(HTTPMethod.post, AppCons.BASE_URL + "Sp/sp_UpSample_v3", parameters: params, encoding: JSONEncoding.default)
                .validate(statusCode: 200 ..< 300)
                .validate({ (request, response, data) -> Request.ValidationResult in
                    if let str = String(data: data!, encoding: .utf8){
                        if let json = Helper.convertToDictionary(text: str) as? NSDictionary{
                            if let result = json["result"] as? NSArray{
                                if let item = result.firstObject as? NSDictionary{
                                    let return_value = item["RETURN_VALUE"] as? Int
                                    let errCode = item["errCode"] as? Int
                                    let errMessage = item["errData"] as? String
                                    if return_value != 0 || errCode != 1 {
                                        return Request.ValidationResult.failure(NSError(domain: errMessage ?? "Unknown error", code: errCode!))
                                    }
                                    
                                }
                            }
                        }
                    }
                    return Request.ValidationResult.success
                })
                .responseJSON()
            
            if let json = sampleData.productJson{
                if let temp = Helper.convertToDictionary(text: json) as? NSArray {
                    for (index, object) in temp.enumerated(){
                        if let item = object as? NSDictionary{
                            var updatedate:Date? = nil
                            if let intDate = item["create_date"] as? UInt64{
                                updatedate = Date(timeIntervalSince1970: TimeInterval(intDate / 1000))
                            }
                            if let prodno = item["prod_id"]{
                                let params = ["line":1,
                                             "reader":1,
                                             "empno": UIDevice.current.identifierForVendor!.uuidString,
                                             "series":sampleData.sampleId,
                                             "prodno": prodno,
                                             "itemExt": "\(index)",
                                            "pcsnum":1]
                                let obItem = manager.rx.request(HTTPMethod.post, AppCons.BASE_URL + "Sp/sp_UpSampleDetail", parameters: params, encoding: JSONEncoding.default)
                                    .validate(statusCode: 200 ..< 300)
                                    .validate({ (request, response, data) -> Request.ValidationResult in
                                        if let str = String(data: data!, encoding: .utf8){
                                            if let json = Helper.convertToDictionary(text: str) as? NSDictionary{
                                                if let result = json["result"] as? NSArray{
                                                    if let item = result.firstObject as? NSDictionary{
                                                        let return_value = item["RETURN_VALUE"] as? Int
                                                        let errCode = item["errCode"] as? Int
                                                        let errMessage = item["errData"] as? String
                                                        if return_value != 0 || errCode != 1 {
                                                            return Request.ValidationResult.failure(NSError(domain: errMessage ?? "Unknown error", code: errCode!))
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        return Request.ValidationResult.success
                                    })
                                    .responseJSON()
                                ob = ob.concat(obItem)
                            }
                        }
                        
                    }
                }
            }
            self.view.makeToastActivity(.center)
            ob.observeOn(MainScheduler.instance)
                .subscribe(onError: {[weak self] (err) in
                    Helper.toast(message: "\(err.localizedDescription)", thisVC: self!)
                }, onCompleted: {
                    
                }, onDisposed: {
                    self.view.hideToastActivity()
                })

            mySampleDAO.create(data: sampleData)
            self.dismiss(animated: true, completion: nil)
            onCompleted?(sampleData)
        }

    }
    
    func toJson(sampleData: MySampleData) -> String? {
        var defaultBizCard = "Anonymous"
        if let settingBizCard = UserDefaults.standard.string(forKey: "bizcard"){
            defaultBizCard = settingBizCard
        }
        let dict:[String : Any] = ["sampleProdLinks": sampleData.productJson,
                    "dataFrom": defaultBizCard,
                    "update_date" :Int64((sampleData.created.timeIntervalSince1970 * 1000.0).rounded()),
                    "guid":sampleData.sampleId]
        return Helper.converToJson(obj: dict)
    }
}
