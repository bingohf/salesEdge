//
//  env.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/19.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
struct Env {
    
    private static let production : Bool = {
        #if DEBUG
        print("DEBUG")
        return false
        #elseif ADHOC
        print("ADHOC")
        return false
        #else
        print("PRODUCTION")
        return true
        #endif
    }()
    
    static func isProduction () -> Bool {
        return self.production
    }
    
}
