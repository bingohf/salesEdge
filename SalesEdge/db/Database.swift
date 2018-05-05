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
                try db?.run(table.create(ifNotExists: true) { t in
                    t.column(prodno, primaryKey: true)
                    t.column(desc)
                    t.column(create_date)
                })
            }catch{
                
            }
        }
    }
}


