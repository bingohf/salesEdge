//
//  ReceivedSampleDAO.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/26.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import CoreData



class ReceivedSampleDAO:CoreDataDAO{
    
    public func findAll()throws ->[ReceivedSampleData] {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "ReceivedSample", in: context)
        let fetchRequest:NSFetchRequest<ReceivedSampleMO> = ReceivedSampleMO.fetchRequest()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "datetime", ascending: false)
        let sortDesciptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDesciptors
        var resListData = [ReceivedSampleData]()
        let listData = try context.fetch(fetchRequest)
        if listData.count > 0{
            for item in listData{
                let mo = item 
                resListData.append(ReceivedSampleData(datetime: mo.datetime! as Date, products: mo.products, title: mo.title!,sampleId: mo.sampleId!, unread_count: 0, graphicUrl:mo.graphicUrl))
            }
        }
        return resListData
    }
    
  
   
    public func create(productsData:[ReceivedSampleData]){
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        for data in productsData{
            let rSample = NSEntityDescription.insertNewObject(forEntityName: "ReceivedSample", into:context) as! ReceivedSampleMO
            rSample.title = data.title
            rSample.datetime = data.datetime as NSDate
            rSample.products = data.products
            rSample.sampleId = data.sampleId
            rSample.graphicUrl = data.graphicUrl
        }
        self.saveContext()
    }
    
    
    public func remove() throws{
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReceivedSample")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try  context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
        }
        
    }
    
}
