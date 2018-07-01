//
//  MySampleData.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/30.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation

struct MySampleData {
    var customer: String?
    var productJson: String?
    var created: NSDate?
    var sampleId: String?
    var line: String?
    var reader: String?
    var mac_address: String?
    var shareToDeviceID: String?
    init(sampleId:String? = nil, customer:String? = nil, created:NSDate? = nil, productJson:String? = nil , line:String? = nil, reader:String? = nil, mac_address:String? = nil, shareToDeviceID:String? = nil){
        self.customer = customer
        self.created = created
        self.sampleId = sampleId
    }
}
