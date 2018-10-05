//
//  Router.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/10/5.
//  Copyright © 2018 Bin Guo. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

enum Router: URLRequestConvertible {
    
    static let baseURLString = "http://ledwayazure.cloudapp.net"
    case ocr(header:[String:String])
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent("ma/ledwayocr.aspx"))
       
        switch self {
        case .ocr(let header):
            return try URLRequest(url: url.appendingPathComponent("ma/ledwayocr.aspx"), method: HTTPMethod.post, headers: header)
        default:
            break
        }
        return urlRequest
    }
}
