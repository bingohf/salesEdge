//
//  CustomTableCell.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/4/15.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import TDBadgedCell

class CustomTableCellView: TDBadgedCell  {
    @IBOutlet weak open var mImage: UIImageView!
    @IBOutlet weak open var mTxtSubTitle: UILabel!
    @IBOutlet weak open var mTxtLabel: UILabel!
    @IBOutlet weak open var mTxtTimestamp: UILabel!
    @IBOutlet weak var mRedFlag: UIView!
}
