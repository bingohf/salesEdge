//
//  ReceivedSample.swift
//  SalesEdge
//
//  Created by Bin Guo on 2019/1/19.
//  Copyright © 2019 Bin Guo. All rights reserved.
//

import Foundation
import CoreData

class ReceivedSample: NSManagedObject {
    @NSManaged var unread_count: NSNumber?
    @NSManaged var from: String?
    @NSManaged var sample_id: String?
    @NSManaged var date: Date?
    @NSManaged var products: Set<ReceivedProduct>?
}
