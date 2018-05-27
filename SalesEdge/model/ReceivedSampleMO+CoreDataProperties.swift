//
//  ReceivedSampleMO+CoreDataProperties.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/26.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReceivedSampleMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceivedSampleMO> {
        return NSFetchRequest<ReceivedSampleMO>(entityName: "ReceivedSample")
    }

    @NSManaged public var datetime: NSDate?
    @NSManaged public var detailJson: String?
    @NSManaged public var title: String?

}
