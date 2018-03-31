//
//  XLPagerViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/3/31.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class XLPagerViewController: UIViewController,IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("APP", comment: ""))
    }
    
    
}
