//
//  File.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/3/3.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftEventBus

class Helper{
    
    
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    private static let jsonFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return formatter
    }()
    
    
    public static func format(date: Date?) -> String{
        if date == nil {
            return ""
        }
        return formatter.string(from:date!)
    }
    
    public static func date(from:String?) -> Date?{
        if let str = from {
            return jsonFormatter.date(from: str)
        }
        return nil
        
    }
    
    public static func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = Helper.CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = (contextImage.cgImage?.cropping(to: rect))!
        let image = resizeImage(image: UIImage(cgImage:imageRef), targetSize: CGSize(width:width, height:height))
        // Create a new image based on the imageRef and rotate back to the original orientation
        //let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    public static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    public static func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    public static func encodeBase64(image:UIImage) -> String{
        let imageData:NSData = image.pngData()! as NSData
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    public static func getErrorMessage<Value>(_ result: Result<Value>) -> String {
        if case let .failure(error) = result {
            if let error = error as? AFError {
                switch error {
                case .invalidURL(let url):
                    return ("Invalid URL: \(url) - \(error.localizedDescription)")
                case .parameterEncodingFailed(let reason):
                    return("Parameter encoding failed: \(error.localizedDescription)")
                    return("Failure Reason: \(reason)")
                case .multipartEncodingFailed(let reason):
                    return("Multipart encoding failed: \(error.localizedDescription)")
                    return("Failure Reason: \(reason)")
                case .responseValidationFailed(let reason):
                    return("Response validation failed: \(error.localizedDescription)")
                    return("Failure Reason: \(reason)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        return("Downloaded file could not be read")
                    case .missingContentType(let acceptableContentTypes):
                        return("Content Type Missing: \(acceptableContentTypes)")
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        return("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                    case .unacceptableStatusCode(let code):
                        return("Response status code was unacceptable: \(code)")
                    }
                case .responseSerializationFailed(let reason):
                    return("Response serialization failed: \(error.localizedDescription)")
                }
                

            } else if let error = error as? URLError {
                return("URLError occurred: \(error.localizedDescription)")
            } else {
                return("Unknown error: \(error.localizedDescription)")
            }
        }
        return ""
    }
    
    public static func setBadge(count:Int){
        SwiftEventBus.post("BadgeValue", sender: count)
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    public static func loadUnReadCount(callback:@escaping ()->Void){
        var params = Helper.makeRequest()
        params.merge(["device_id": UIDevice.current.identifierForVendor!.uuidString
        ]) { (any1, any2) -> Any in
            any2
        }
        Alamofire.request(AppCons.SE_Server + "SpDataSet/SP_GET_MESSAGECOUNT", method: .post, parameters: params,encoding: JSONEncoding.default)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                if let error = response.result.error {
                    callback()
                    return
                }
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSArray
                for object in array{
                    if let item = object as? NSDictionary{
                        if let count = item.value(forKey: "count") as? Int{
                            setBadge(count: count)
                        }
                    }
                }
                callback()
        }
    }
    
    public static func generateQRCode(from string: String) -> CIImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            return filter.outputImage

        }
        
        return nil
    }

    public static func getImagePath(folder:String) -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent(folder)
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        return dataPath
    }
    
    public static func getImagePath(folder:String, prodno:String, type:String) ->URL{
        let dataPath = getImagePath(folder: folder)
        if type == "Main"{
            return dataPath.appendingPathComponent("\(prodno)_type1.png")
        }
        return dataPath.appendingPathComponent("\(prodno)_\(type)_1.png")
    }
    
    
    public static func setUploaded(file:URL) {
        let fileManager = FileManager.default
        let fileattr = try? fileManager.attributesOfItem(atPath: file.path)
        if let modifiedDate = fileattr?[FileAttributeKey.modificationDate] as? NSDate {
            try? "\(modifiedDate)".write(to: URL.init(fileURLWithPath: file.path + "_\(modifiedDate.timeIntervalSince1970)"), atomically: true, encoding: String.Encoding.utf8)
        }
    }
    
    public static func isUploaded(file:URL) -> Bool{
        let fileManager = FileManager.default
        let fileattr = try? fileManager.attributesOfItem(atPath: file.path)
        if let modifiedDate = fileattr?[FileAttributeKey.modificationDate] as? NSDate {
            return fileManager.fileExists(atPath: file.path + "_\(modifiedDate.timeIntervalSince1970)");
        }
        return false;
    }
    
    
    public static func makeRequest() -> [String : Any] {
        let line = UserDefaults.standard.object(forKey: "line") as! String?
        let myTaxNo = UserDefaults.standard.object(forKey: "myTaxNo") as! String?
        return [
            "line" : "\(line ?? "01")",
            "reader" : "01",
            "MyTaxNo" : getMyTaxNO(),
            "pdaGuid": pdaGuid()
        ]
    }
    
    public static func pdaGuid() -> String {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString;
        let deviceName = UIDevice.current.modelName
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyyMMdd'T'HHmmss.S"
        let timeStamp = dformatter.string(from: Date.init())
        var language = Locale.preferredLanguages.first!
        var languageArr = language.components(separatedBy: "-")
        while languageArr.count > 2 {
            languageArr.remove(at: 1)
        }
        language = languageArr.joined(separator: "_")
        return "\(deviceId)-\(deviceName)-LEDWAY-\(timeStamp)~\(language)"
    }
    
    public static func getMyTaxNO()->String{
        let myTaxNo = UserDefaults.standard.object(forKey: "myTaxNo") as! String?
        if let myTaxno = myTaxNo {
            if !myTaxno.isEmpty{
                return myTaxno
            }
        }
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    
    public static func toast(message:String, thisVC:UIViewController) {
        var vc:UIViewController? = thisVC
        while ((vc?.parent) != nil)  {
            vc = vc?.parent
        }
        if let vc = vc {
            vc.view.makeToast(message)
        }
    }
    
    public static func convertToDictionary(text: String) -> Any? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public static func converToJson(obj:Any) -> String?{
        do{
            let data =  try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }catch{
            return ""
        }
    }
}


public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}


extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
