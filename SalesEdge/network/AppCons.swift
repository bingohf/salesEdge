//
//  AppCons.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/30.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation


struct AppCons {

    
   
    static var SM_Server:String = "http://ledwayvip.cloudapp.net:8080/datasnap/rest/TLwDataModule/"
    static var SE_Server:String = "http://ledwayvip.cloudapp.net:8080/datasnap/rest/TLwDataModule/"
    public static func loadServer(){
        let sm_server = UserDefaults.standard.string(forKey: "sm_server") ?? "http://ledwayvip.cloudapp.net"
        let sm_port = UserDefaults.standard.string(forKey: "sm_port") ?? "8080"
        let str =  "\(sm_server):\(sm_port)/datasnap/rest/TLwDataModule/"
        SM_Server = str
        loadServer_Se()
    }
    
    public static func loadServer_Se(){
        let sm_server = UserDefaults.standard.string(forKey: "se_server") ?? "http://ledwayvip.cloudapp.net"
        let sm_port = UserDefaults.standard.string(forKey: "se_port") ?? "8080"
        let str =  "\(sm_server):\(sm_port)/datasnap/rest/TLwDataModule/"
        SE_Server = str
    }
    
    
    
}
