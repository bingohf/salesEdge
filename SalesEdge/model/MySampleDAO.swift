//
//  MySampleDAO.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/30.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import CoreData
class MySampleDAO:CoreDataDAO{
    
    public func findAll()throws ->[MySampleData] {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "MySample", in: context)
        let fetchRequest:NSFetchRequest<MySample> = MySample.fetchRequest()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let sortDesciptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDesciptors
        var resListData = [MySampleData]()
        let listData = try context.fetch(fetchRequest)
        if listData.count > 0{
            for item in listData{
                let mo = item 
                resListData.append(MySampleData(sampleId: mo.sampleId, customer: mo.customer, created: mo.created, productJson: mo.productJson, line:mo.line, reader:mo.reader, mac_address:mo.mac_address, shareToDeviceID:mo.shareToDeviceID, update_date:mo.upload_date,
                                                email_list: mo.email_list ?? "", auto_send_on: mo.auto_send_on))
            }
        }
        return resListData
    }
    
    public func create(data:MySampleData){
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let mySample = NSEntityDescription.insertNewObject(forEntityName: "MySample", into:context) as! MySample
        mySample.customer = data.customer
        mySample.created = data.created
        mySample.productJson = data.productJson
        mySample.sampleId = data.sampleId
        mySample.shareToDeviceID = data.shareToDeviceID
        mySample.dataFrom = data.dataFrom
        mySample.reader = data.reader
        mySample.line = data.line
        mySample.upload_date = data.upload_date
        mySample.auto_send_on = data.auto_send_on
        mySample.email_list = data .email_list
        self.saveContext()
    }
    
    public func remove(data:MySampleData) {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "MySample", in: context)
        let fetchRequest:NSFetchRequest<MySample> = MySample.fetchRequest()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "sampleId = %@", data.sampleId ?? "")
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object)
            }
        }
        self.saveContext()
        
    }
}
