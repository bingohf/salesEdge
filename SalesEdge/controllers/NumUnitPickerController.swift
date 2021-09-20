//
//  NumUnitPickerController.swift
//  SalesEdge
//
//  Created by bingo on 2021/9/12.
//  Copyright © 2021 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class NumUnitPickerController:UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var mStateType: UIPickerView!
    let list = [["Hanger","Swatch","Fabric"], ["1","2", "3", "4", "5", "6", "7", "8", "9", "10"], ["PCS","Meter","Yard"]]
    
    override func viewDidLoad() {
  
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1{
            return 100
        }
        return list[component].count
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1{
            return "\(row + 1)"
        }
        return list[component][row]
    }
    
    open func setValues(stateType:String?, pcsnum:Int, unit:String?){
        for (index,item) in list[0].enumerated(){
            if item == stateType{
                mStateType.selectRow(index, inComponent: 0, animated: false)
            }
        }
        mStateType.selectRow(pcsnum - 1, inComponent: 1, animated: false)
        for (index,item) in list[2].enumerated(){
            if item == unit{
                mStateType.selectRow(index, inComponent: 2, animated: false)
            }
        }
    }
    
    
    open func getValues()->(String, String, String){
        return (list[0][mStateType.selectedRow(inComponent: 0)], "\(mStateType.selectedRow(inComponent: 1) + 1)", list[2][mStateType.selectedRow(inComponent: 2)])
    }
}

