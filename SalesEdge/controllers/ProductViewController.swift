//
//  ProductViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/6.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

protocol ProductDelegate {
    func onDataChange(productData: ProductData)
}

public class ProductViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var productData:ProductData? = nil
    var delegate:ProductDelegate? = nil
    
    @IBOutlet weak var mTxtDesc: UITextField!
    @IBOutlet weak var mImage: UIImageView!
    override public func viewDidLoad() {
        mTxtDesc.text = productData?.desc
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let prodno = productData?.prodno{
            let filePath = documentsDirectory.appendingPathComponent("Show").appendingPathComponent("\(prodno)_type1.png")
            do{
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath.path){
                    mImage.image = UIImage(contentsOfFile: filePath.path)
                }
                
            }catch{
                print(error)
            }
        }
        

    }
    @IBAction func onTapGestureSelector(_ sender: Any) {
        if let guesture = sender as? UITapGestureRecognizer {
            if guesture.view === mImage {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    

    
    @IBAction func onUploadTouch(_ sender: Any) {
        productData?.desc = mTxtDesc.text
        delegate?.onDataChange(productData: productData!)
        self.navigationController?.popViewController(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

    }
    
}
