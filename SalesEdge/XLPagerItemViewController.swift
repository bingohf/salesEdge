//
//  XLPagerViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/3/31.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class XLPagerItemViewController: UIViewController,IndicatorInfoProvider {
    
    var itemInfo = IndicatorInfo(title: "View")
    
    public func setInfo(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
    }

    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
}
