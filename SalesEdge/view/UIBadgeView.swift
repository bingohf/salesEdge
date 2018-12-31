//
//  UIBadgeView.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/12/31.
//  Copyright © 2018 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UIBadgeView : UILabel{
    
    @IBInspectable var topInset: CGFloat = 2.0
    @IBInspectable var bottomInset: CGFloat = 2
    @IBInspectable var leftInset: CGFloat = 2
    @IBInspectable var rightInset: CGFloat = 2
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.red
        self.textColor = UIColor.white
        self.font = UIFont.systemFont(ofSize: 12)
        self.sizeToFit()

    }
    
//    override func drawText(in rect: CGRect) {
//        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
//
//        super.drawText(in: rect.insetBy(dx: insets.left, dy: insets.top))
//    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

