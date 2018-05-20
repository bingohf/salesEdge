//
//  ProductManagedObject+CoreDataProperties.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/12.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//
//

import Foundation
import CoreData


extension ProductManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductManagedObject> {
        return NSFetchRequest<ProductManagedObject>(entityName: "Product")
    }

    @NSManaged public var prodno: String?
    @NSManaged public var desc: String?
    @NSManaged public var updatedate: NSDate?

}
