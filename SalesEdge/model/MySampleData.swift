//
//  MySampleData.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/30.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation

class MySampleData {
    var customer: String?
    var productJson: String?
    var created: NSDate
    var sampleId: String?
    var line: String?
    var reader: String?
    var mac_address: String?
    var shareToDeviceID: String?
    var dataFrom: String?
    var upload_date: NSDate?
    var isDirty:Bool = false
    init(sampleId:String? = nil, customer:String? = nil, created:NSDate? = NSDate(), productJson:String? = nil , line:String? = nil, reader:String? = nil, mac_address:String? = nil, shareToDeviceID:String? = nil, dataFrom:String? = nil, update_date:NSDate? = nil){
        self.customer = customer
        self.created = created ?? NSDate()
        self.sampleId = sampleId
        self.productJson = productJson ?? "[]"
        self.line = line
        self.reader = reader
        self.mac_address = mac_address
        self.shareToDeviceID = shareToDeviceID
        self.dataFrom = dataFrom
        self.upload_date = update_date
    }
    
    func toDictionary() -> NSDictionary {
        let ret = NSDictionary()
        ret.setValue(customer, forKey: "customer")
        ret.setValue(productJson, forKey: "productJson")
        ret.setValue(created, forKey: "created")
        ret.setValue(sampleId, forKey: "sampleId")
        ret.setValue(line, forKey: "line")
        ret.setValue(reader, forKey: "reader")
        ret.setValue(mac_address, forKey: "mac_address")
        ret.setValue(shareToDeviceID, forKey: "shareToDeviceID")
        ret.setValue(dataFrom, forKey: "dataFrom")
        ret.setValue(upload_date, forKey: "update_date")
        return ret
    }
}
