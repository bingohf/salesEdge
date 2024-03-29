//
//  Extensions.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/13.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit


extension String{
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIView {
    
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
//        }
//    }
//    
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//    
//    @IBInspectable var borderColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
//    }
}
