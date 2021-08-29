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
    @IBOutlet weak open var mTxtTimestamp: UILabel?
    @IBOutlet weak open var mTxtPcsNum: UILabel!
    @IBOutlet weak open var mTxtMemo: UILabel!
    @IBOutlet weak var mRedFlag: UIView!
    @IBOutlet weak var mBtnAdd: UIButton!
    @IBOutlet weak var mBtnSub: UIButton!
    var index :Int = 0
    private var _pcsnum = 0
    var pcsnum :Int{
        set(value){
            if value < 1 || value > 99{
                return
            }
            _pcsnum = value
            mTxtPcsNum.text = "\(value)"
            onPcsChange?(value, self)
        }
        get{
            return _pcsnum
        }
    }
    var onPcsChange:((_ value:Int,_ cell:CustomTableCellView)->Void)? = nil
    var onMemoBtnCallback:((_ index:Int)->Void)? = nil
    @IBAction func onStepperBtnTouch(_ sender: Any) {
        if let btn = sender as? UIButton{
            if btn.currentTitle == "-"{
                pcsnum = pcsnum - 1
            }else{
                pcsnum = pcsnum + 1
            }
        }
        
    }
    
    
    @IBAction func onMemoBtnTouch(_ sender: Any) {
        onMemoBtnCallback?(index)
    }
}
