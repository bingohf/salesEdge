//
//  ReceivedProduct.swift
//  SalesEdge
//
//  Created by Bin Guo on 2019/1/19.
//  Copyright © 2019 Bin Guo. All rights reserved.
//

import Foundation
import CoreData

class ReceivedProduct: NSManagedObject {
    @NSManaged var prod_no: String?
    @NSManaged var spec: String?
    @NSManaged var image_url: String?
    @NSManaged var sample: ReceivedSample?
    @NSManaged var date: Date?
}
