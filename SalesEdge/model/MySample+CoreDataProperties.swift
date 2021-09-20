//
//  MySample+CoreDataProperties.swift
//  
//
//  Created by bingo on 2021/9/20.
//
//

import Foundation
import CoreData


extension MySample {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySample> {
        return NSFetchRequest<MySample>(entityName: "MySample")
    }

    @NSManaged public var created: Date?
    @NSManaged public var customer: String?
    @NSManaged public var dataFrom: String?
    @NSManaged public var line: String?
    @NSManaged public var mac_address: String?
    @NSManaged public var productJson: String?
    @NSManaged public var reader: String?
    @NSManaged public var sampleId: String?
    @NSManaged public var shareToDeviceID: String?
    @NSManaged public var upload_date: Date?
    @NSManaged public var email_list: String?
    @NSManaged public var auto_send_on: Date?

}
