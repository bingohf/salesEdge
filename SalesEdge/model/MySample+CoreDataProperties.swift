//
//  MySample+CoreDataProperties.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/7/14.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//
//

import Foundation
import CoreData


extension MySample {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySample> {
        return NSFetchRequest<MySample>(entityName: "MySample")
    }

    @NSManaged public var created: NSDate?
    @NSManaged public var customer: String?
    @NSManaged public var line: String?
    @NSManaged public var mac_address: String?
    @NSManaged public var productJson: String?
    @NSManaged public var reader: String?
    @NSManaged public var sampleId: String?
    @NSManaged public var shareToDeviceID: String?
    @NSManaged public var dataFrom: String?

}
