//
//  MemoryDiskCache.swift
//  SalesEdge
//
//  Created by Bin Guo on 2019/1/5.
//  Copyright © 2019 Bin Guo. All rights reserved.
//

import Foundation
import AlamofireImage
import Disk
import CommonCrypto


open class MemoryDiskCache:ImageRequestCache{
    
    let memoryCache = AutoPurgingImageCache()
    public func add(_ image: Image, for request: URLRequest, withIdentifier identifier: String?) {
        memoryCache.add(image, for: request, withIdentifier: identifier)
        let url = (request.url?.absoluteString)!
        let hashUrl = md5(url)
        do {
            try Disk.save(image, to: .caches, as: hashUrl)
        }catch{
            print(error)
        }
    }
    
    public func removeImage(for request: URLRequest, withIdentifier identifier: String?) -> Bool {
        return memoryCache.removeImage(for: request, withIdentifier: identifier)
    }
    
    func md5(_ string:String) -> String {
        let str = string.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(string.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }

    public func image(for request: URLRequest, withIdentifier identifier: String?) -> Image? {
       var image = memoryCache.image(for: request, withIdentifier: identifier)

        if image == nil{
            do{
                let url = (request.url?.absoluteString)!
                let hashUrl = md5(url)
                image = try Disk.retrieve(hashUrl, from: .caches, as: UIImage.self)
                if let image = image {
                    memoryCache.add(image, for: request, withIdentifier: identifier)
                }
            }catch{
                print(error)
            }
        }
        return image
    }
    
    public func add(_ image: Image, withIdentifier identifier: String) {
        memoryCache.add(image, withIdentifier: identifier)
    }
    
    public func removeImage(withIdentifier identifier: String) -> Bool {
        return  memoryCache.removeImage(withIdentifier: identifier)
    }
    
    public func removeAllImages() -> Bool {
        return memoryCache.removeAllImages()
    }
    
    public func image(withIdentifier identifier: String) -> Image? {
        return memoryCache.image(withIdentifier:identifier)
    }
    
    
}

