//
//  Database.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/15.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import SQLite


class LDataBase {
    static let shared = LDataBase()
    var db:Connection?
    let product:Product
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        print(path)
        db = try? Connection("\(path)/db.sqlite3")
        product = Product(db: db)
    }
    
    class Product{
        let table = Table("product")
        let prodno = Expression<String>("prodno")
        let desc = Expression<String>("desc")
        let create_date = Expression<Date>("create_date")
        init(db:Connection?) {
        
                do {
                    let rowid = try db?.run(table.insert(prodno <- "alice@mac.com", desc <- "", create_date <- Date()))
                    print("inserted id: \(String(describing: rowid))")
                } catch {
                    print("insertion failed: \(error)")
                }
        }
    }
}


