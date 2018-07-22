//
//  ProductDAO.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/12.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import CoreData

class ProductDAO:CoreDataDAO{
    
    public func findAll()throws ->[ProductData] {
        let o :ReceivedSampleMO?
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let fetchRequest:NSFetchRequest<ProductManagedObject> = ProductManagedObject.fetchRequest()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "updatedate", ascending: false)
        let sortDesciptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDesciptors
        var resListData = [ProductData]()
        let listData = try context.fetch(fetchRequest)
        if listData.count > 0{
            for item in listData{
                let mo = item as! ProductManagedObject
                resListData.append(ProductData(prodno: mo.prodno ?? "", desc: mo.desc, updatedate: mo.updatedate as! Date))
            }
        }
        return resListData
    }
    
    public func findBy(prodno:String) throws -> ProductData?{
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let fetchRequest:NSFetchRequest<ProductManagedObject> = ProductManagedObject.fetchRequest()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "prodno = %@", prodno)
        let listData = try context.fetch(fetchRequest)
        if let data = listData.first as? ProductManagedObject {
            return ProductData(prodno: prodno, desc: data.desc, updatedate: data.updatedate as! Date)
        }
        return nil
    }
    
    public func removeAll() throws {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(batchDeleteRequest)
    }
    
    public func create(data:ProductData){
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into:context) as! ProductManagedObject
        product.prodno = data.prodno
        product.desc = data.desc
        product.updatedate = data.updatedate as! NSDate
        self.saveContext()
    }
    
    public func create(productsData:[ProductData]){
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        for data in productsData{
            let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into:context) as! ProductManagedObject
            product.prodno = data.prodno
            product.desc = data.desc
            product.updatedate = data.updatedate as! NSDate
        }
        self.saveContext()
    }
    
    
    public func remove(productData:ProductData) throws{
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let fetchRequest:NSFetchRequest<ProductManagedObject> = ProductManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "prodno=%@", productData.prodno)
        let listData = try context.fetch(fetchRequest)
        if listData.count > 0{
            let product = listData.first as! ProductManagedObject
            context.delete(product)
            self.saveContext()
        }
    }
    
}
