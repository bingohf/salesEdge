//
//  ReceivedSampleMO+CoreDataProperties.swift
//  
//
//  Created by Bin Guo on 2019/1/5.
//
//

import Foundation
import CoreData


extension ReceivedSampleMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceivedSampleMO> {
        return NSFetchRequest<ReceivedSampleMO>(entityName: "ReceivedSample")
    }

    @NSManaged public var datetime: NSDate?
    @NSManaged public var sampleId: String?
    @NSManaged public var title: String?
    @NSManaged public var graphicUrl: String?
    @NSManaged public var products: String?

}
