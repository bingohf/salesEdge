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

public class ProductViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UITextViewDelegate, URLConvertible{
    var productData:ProductData? = nil
    var delegate:ProductDelegate? = nil
    var afterPickImage :(() -> Void)?
    
    @IBOutlet weak var mTxtDesc: UITextView!
    @IBOutlet weak var mImage: UIImageView!
    
    @IBOutlet weak var mLabelPlaceHold: UILabel!
    @IBOutlet weak var mBtnQRCode: UIButton!
    override public func viewDidLoad() {
        mBtnQRCode.contentMode = .center
        mBtnQRCode.imageView?.contentMode = .scaleAspectFit
        mTxtDesc.text = productData?.desc
        mLabelPlaceHold.isHidden = !mTxtDesc.text.isEmpty
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let prodno = productData?.prodno{
            let filePath = documentsDirectory.appendingPathComponent("Show").appendingPathComponent("\(prodno)_type1.png")
            do{
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath.path){
                    mImage.image = UIImage(contentsOfFile: filePath.path)
                    mImage.contentMode = .scaleToFill
                    mImage.contentMode = .scaleAspectFit
                }
                
            }catch{
                print(error)
            }
        }
        
        
    }
    @IBAction func onTapGestureSelector(_ sender: Any) {
        if let guesture = sender as? UITapGestureRecognizer {
            if guesture.view === mImage {
                let prodno = productData!.prodno
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let filePath = documentsDirectory.appendingPathComponent("Show").appendingPathComponent("\(prodno)_type1.png")
                do{
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: filePath.path){
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                        vc.imageUrl = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_type1.png")
                        show(vc, sender: sender)
                    }else{
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "CombinImagePickerViewController") as! CombinImagePickerViewController
                        vc.onCompleted = {[weak self] image in
                            if let image = image {
                                let image512 = Helper.cropToBounds(image: image, width: 512, height: 512)
                                let image110 = Helper.cropToBounds(image: image512, width: 110, height: 110)
                                self?.mImage.image = image
                                self?.mImage.contentMode = .scaleToFill
                                let dataPath = Helper.getImagePath(folder: "Show")
                                if let data512 = UIImagePNGRepresentation(image512) {
                                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type1.png")
                                    try? data512.write(to: filename)
                                }
                                if let data110 = UIImagePNGRepresentation(image110) {
                                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type2.png")
                                    try? data110.write(to: filename)
                                }
                                self?.afterPickImage?()
                                self?.afterPickImage = nil
                            }
                
                        
                        }
                        present(vc, animated: true, completion: nil)
                    }
                    
                }catch{
                    print(error)
                }
                
                
            
                
    
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
            Alamofire.request(AppCons.BASE_URL + "Sp/sp_UpProductLine", method: .post, parameters: params, encoding: JSONEncoding.default)
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
        if let data512 = UIImageJPEGRepresentation(image512, 1) {
            let filename = dataPath.appendingPathComponent("\(productData?.prodno ?? "")_type1.png")
            try? data512.write(to: filename)
        }
        if let data110 = UIImageJPEGRepresentation(image110, 1) {
            let filename = dataPath.appendingPathComponent("\(productData?.prodno ?? "")_type2.png")
            try? data110.write(to: filename)
        }
        afterPickImage?()
        afterPickImage = nil
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan_qrcode" {
            let destinationVC = segue.destination as? QRCodeScannerViewController
            destinationVC?.onCompleted = { [weak self](qrcode) in
                self?.mTxtDesc.text = qrcode
            }
        }
        if segue.identifier == "take_photo" {
            let imagePicker = segue.destination as! UIImagePickerController
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
        }
    }

    
    public func asURL() throws -> URL {
        return URL(string: "http://ledwayazure.cloudapp.net/ma/ledwayocr.aspx")!
    }
      
    @IBAction func onBtnOCRTouch(_ sender: Any) {
        mTxtDesc.endEditing(true)
        let oldText = mTxtDesc.text ?? ""
        let image1Path = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_type1.png")
        guard oldText.isEmpty else {
             Helper.toast(message: NSLocalizedString("Please clear description", comment:""), thisVC: self)
            return
        }
        guard FileManager.default.fileExists(atPath: image1Path.path) else {
            Helper.toast(message: NSLocalizedString("Please take a photo", comment:""), thisVC: self)
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
            func doOCR() -> Void {
               self.onBtnOCRTouch(mBtnQRCode)
            }
            self.afterPickImage = doOCR
            return
        }
        var userName = Helper.getMyTaxNO()
        if !Env.isProduction(){
           // userName = "b46fe30b737a24ef-MI 5-LEDWAY-20180519T163532.7~zh_CN"
        }
    
        let inputStream = InputStream(url:image1Path)
        let headers = ["content-type":"application/octet-stream", "UserName" : userName, "PASSWORD":"8887#@Ledway"]
        self.view.makeToastActivity(.center)
        Alamofire.upload(image1Path, to: self, method: .post, headers: headers)
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
                let errCode = JSON.value(forKey: "returnCode") as? Int
                let errMessage = JSON.value(forKey: "returnInfo") as? String
                guard errCode == 1 else{
                    Helper.toast(message: errMessage ?? "error", thisVC: self)
                    return
                }
                let jsonStr = JSON.value(forKey: "data") as? String
                if let data = Helper.convertToDictionary(text: jsonStr ?? "") as? NSDictionary{
                    let limit = data["OCRLimit"] as! Int
                    let count = data["OCRCount"] as! Int
                    let text = data["OCRInfo"] as! String
                    if limit - count <= 100{
                        Helper.toast(message: "OCR has been used \(limit) time(s) (Limit:\(count)", thisVC: self)
                    }
                    self.mTxtDesc.text = text
                    self.mLabelPlaceHold.isHidden = !text.isEmpty
                }
                
                
        }
    }
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    public func textViewDidChange(_ textView: UITextView) {
        self.mLabelPlaceHold.isHidden = !textView.text.isEmpty
    }
    
    @IBAction func onActionPhotoTouch(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CombinImagePickerViewController") as! CombinImagePickerViewController
        vc.onCompleted = {[weak self] image in
            if let image = image {
                let image512 = Helper.cropToBounds(image: image, width: 512, height: 512)
                let image110 = Helper.cropToBounds(image: image512, width: 110, height: 110)
                self?.mImage.image = image
                self?.mImage.contentMode = .scaleToFill
                let dataPath = Helper.getImagePath(folder: "Show")
                if let data512 = UIImagePNGRepresentation(image512) {
                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type1.png")
                    try? data512.write(to: filename)
                }
                if let data110 = UIImagePNGRepresentation(image110) {
                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type2.png")
                    try? data110.write(to: filename)
                }
                self?.afterPickImage?()
                self?.afterPickImage = nil
            }
            
            
        }
        present(vc, animated: true, completion: nil)
    }
}
