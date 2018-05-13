//
//  ProductViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/5/6.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol ProductDelegate {
    func onDataChange(productData: ProductData)
}

public class ProductViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, QRCodeScannerDelegate{
    var productData:ProductData? = nil
    var delegate:ProductDelegate? = nil
    
    @IBOutlet weak var mTxtDesc: UITextView!
    @IBOutlet weak var mImage: UIImageView!
    
    @IBOutlet weak var mBtnQRCode: UIButton!
    override public func viewDidLoad() {
        mBtnQRCode.contentMode = .center
        mBtnQRCode.imageView?.contentMode = .scaleAspectFit
        mTxtDesc.text = productData?.desc
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let prodno = productData?.prodno{
            let filePath = documentsDirectory.appendingPathComponent("Show").appendingPathComponent("\(prodno)_type1.png")
            do{
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath.path){
                    mImage.image = UIImage(contentsOfFile: filePath.path)
                    mImage.contentMode = .scaleToFill
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
        mTxtDesc.endEditing(true)
        let desc = mTxtDesc.text ?? ""
        guard !desc.isEmpty else {
            Helper.toast(message:"Please input Product description", thisVC:self)
            return
        }
        let image1Path = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_type1.png")
        let image2Path = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_type2.png")
        guard FileManager.default.fileExists(atPath: image1Path.path) else {
            Helper.toast(message:"Please take a image for this product", thisVC:self)
            return
        }
        productData?.desc = desc
        productData?.updatedate = Date()
        
        if let imageData1:NSData = NSData(contentsOf: image1Path),
            let imageData2 = NSData(contentsOf: image2Path){
            let strBase641 = imageData1.base64EncodedString(options: .lineLength64Characters)
            let strBase642 = imageData2.base64EncodedString(options: .lineLength64Characters)
            var params = Helper.makeRequest()
            params.merge(["prodno": productData?.prodno ?? "",
                          "specdesc" : desc,
                          "empno": UIDevice.current.identifierForVendor!.uuidString,
                          "graphic" : strBase641,
                          "graphic2" : strBase642
            ]) { (any1, any2) -> Any in
                any2
            }
            self.view.makeToastActivity(.center)
            Alamofire.request(AppCons.BASE_URL + "Sp/sp_UpProduct", method: .post, parameters: params, encoding: JSONEncoding.default)
                .debugLog()
                .validate(statusCode: 200..<300)
                .responseJSON{
                    response in
                    self.view?.hideToastActivity()
                    if let error = response.result.error {
                        Helper.toast(message: Helper.getErrorMessage(response.result), thisVC: self)
                        return
                    }
                    let value = response.result.value
                    let JSON = value as! NSDictionary
                    let result = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSDictionary
                    let errCode = result.value(forKey: "errCode") as? Int
                    let errMessage = result.value(forKey: "errData") as? String
                    guard errCode == 1 else{
                        Helper.toast(message: errMessage ?? "error", thisVC: self)
                        return
                    }
                    let productDAO = ProductDAO()
                    productDAO.create(data: self.productData!)
                    self.delegate?.onDataChange(productData: self.productData!)
                    self.navigationController?.popViewController(animated: true)
            }
        }
        
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let image512 = Helper.cropToBounds(image: image, width: 512, height: 512)
        let image110 = Helper.cropToBounds(image: image512, width: 110, height: 110)
        mImage.image = image
        mImage.contentMode = .scaleToFill
        let dataPath = Helper.getImagePath(folder: "Show")
        if let data512 = UIImagePNGRepresentation(image512) {
            let filename = dataPath.appendingPathComponent("\(productData?.prodno ?? "")_type1.png")
            try? data512.write(to: filename)
        }
        if let data110 = UIImagePNGRepresentation(image110) {
            let filename = dataPath.appendingPathComponent("\(productData?.prodno ?? "")_type2.png")
            try? data110.write(to: filename)
        }
        
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan_qrcode" {
            let destinationVC = segue.destination as? QRCodeScannerViewController
            destinationVC?.delegate = self
        }
    }
    
    func onReceive(qrcode: String) {
        mTxtDesc.text = qrcode
    }
}
