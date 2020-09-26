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
import ALCameraViewController

protocol ProductDelegate {
    func onDataChange(productData: ProductData)
}

public class ProductViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UITextViewDelegate, URLConvertible, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    
    var productData:ProductData? = nil
    var delegate:ProductDelegate? = nil
    var afterPickImage :(() -> Void)?
    let dataPath = Helper.getImagePath(folder: "Show")
    let fileManager = FileManager.default
    @IBOutlet weak var mTxtDesc: UITextView!

    @IBOutlet weak var mCollectionView: UICollectionView!
    
    @IBOutlet weak var mLabelPlaceHold: UILabel!
    @IBOutlet weak var mBtnQRCode: UIButton!
    
    
    public static let pictureTypes = ["Main" , "Left" ,"Flat", "Down", "Front", "Bent", "Right"]
    let pictureTypes = ProductViewController.pictureTypes
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProductViewController.pictureTypes.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell :ProductCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) as! ProductCollectionViewCell
        let index = indexPath.row
        cell.image.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.06)
        cell.label.text = ProductViewController.pictureTypes[indexPath.row]
        cell.label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        cell.btnChange.tag = indexPath.row
        cell.btnChange.addTarget(self, action: #selector(onBtnChangeClick), for: UIControl.Event.touchUpInside)
        let filename = Helper.getImagePath(folder: "Show", prodno: productData?.prodno ?? "", type: pictureTypes[indexPath.row])
        if fileManager.fileExists(atPath: filename.path){
           cell.image.image = UIImage(contentsOfFile: filename.path)
           cell.image.contentMode = .scaleToFill
           cell.image.contentMode = .scaleAspectFit
        }
        
        return cell
        
    }
    
    @objc func onBtnChangeClick(sender:UIButton){
        print("onBtnChangeClick\(sender.tag)")
        let index = sender.tag
        takePhotoFor(index: index)
    }
    
    
    func takePhotoFor(index:Int) {
        if index == 0{
            onActionPhotoTouch(mCollectionView)
            return
        }
        
        let croppingParmaters = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width:120,height:120))
        let cameraViewController = CameraViewController(croppingParameters: croppingParmaters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true)
        { [weak self] image, asset in
            if let image = image {
                let image512 = Helper.cropToBounds(image: image, width: 1024, height: 1024)
                if let data512 = image512.jpegData(compressionQuality: 1) {
                    if let filename = self?.dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_\(ProductViewController.pictureTypes[index] )_1.png"){
                       try? data512.write(to: filename)
                        self?.mCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                    }
                }
                let image256 = Helper.cropToBounds(image: image, width: 256, height: 256)
                
                if let data256 = image256.jpegData(compressionQuality: 1) {
                    if let filename = self?.dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_\(ProductViewController.pictureTypes[index] )_2.png"){
                       try? data256.write(to: filename)
                    }
                }
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat;
        if pictureTypes[indexPath.row] == "Main"{
            size = (collectionView.frame.size.width - space)
        }else{
            size = (collectionView.frame.size.width - space) / 2.0
        }
        return CGSize(width: size, height: size)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView didSelectItemAt \(indexPath)")
        let index = indexPath.row
        let filename = Helper.getImagePath(folder: "Show", prodno: productData?.prodno ?? "", type: pictureTypes[indexPath.row])
        if fileManager.fileExists(atPath: filename.path){
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
           vc.imageUrl = filename
           show(vc, sender: collectionView)
        }else{
            takePhotoFor(index: index)
        }
        
    }
    

    override public func viewDidLoad() {
        mBtnQRCode.contentMode = .center
        mBtnQRCode.imageView?.contentMode = .scaleAspectFit
        mTxtDesc.text = productData?.desc
        mLabelPlaceHold.isHidden = !mTxtDesc.text.isEmpty
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let prodno = productData?.prodno{
            let filePath = documentsDirectory.appendingPathComponent("Show").appendingPathComponent("\(prodno)_type1.png")
            do{
                
                if fileManager.fileExists(atPath: filePath.path){
//                    mImage.image = UIImage(contentsOfFile: filePath.path)
//                    mImage.contentMode = .scaleToFill
//                    mImage.contentMode = .scaleAspectFit
                }
                
            }catch{
                print(error)
            }
        }
        
        
    }
    @IBAction func onTapGestureSelector(_ sender: Any) {
/*        if let guesture = sender as? UITapGestureRecognizer {
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
                                if let data512 = image512.pngData() {
                                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type1.png")
                                    try? data512.write(to: filename)
                                }
                                if let data110 = image110.pngData() {
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
 */
    }
    
    
    func uploadImages(typeIndex:Int,   callback: @escaping ()->Void)   {
        guard typeIndex < ProductViewController.pictureTypes.count else {
            callback()
            return
        }
        let type = ProductViewController.pictureTypes[typeIndex]
        let imagePath = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_\(type)_1.png")
        if !FileManager.default.fileExists(atPath: imagePath.path) {
            uploadImages(typeIndex: typeIndex + 1, callback: callback);
            return;
        }
        let imagePath2 = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_\(type)_2.png")
       // Helper.toast(message: "Uploading \(type)", thisVC: self)
        let fincallback = callback
        if let imageData:NSData = NSData(contentsOf: imagePath),
           let imageData2:NSData = NSData(contentsOf: imagePath2){
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            let strBase642 = imageData2.base64EncodedString(options: .lineLength64Characters)
            var params = Helper.makeRequest()
                       params.merge(["prodno": productData?.prodno ?? "",
                                     "empno": UIDevice.current.identifierForVendor!.uuidString,
                                     "graphic" : strBase64,
                                     "graphic2" : strBase642,
                                     "type" : type
                       ]) { (any1, any2) -> Any in
                           any2
                       }
            Alamofire.request(AppCons.SE_Server + "Sp/sp_UpProductLineImage", method: .post, parameters: params, encoding: JSONEncoding.default)
                .debugLog()
                .validate(statusCode: 200..<300)
                .responseJSON{
                    response in
                    if let error = response.result.error {
                        self.view?.hideToastActivity()
                        Helper.toast(message: Helper.getErrorMessage(response.result), thisVC: self)
                        return
                    }
                    print(response.data)
                    let value = response.result.value
                    print(value)
                    let JSON = value as! NSDictionary
                    let result = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSDictionary
                    let errCode = result.value(forKey: "errCode") as? Int
                    let errMessage = result.value(forKey: "errData") as? String
                    guard errCode == 1 else {
                        self.view?.hideToastActivity()
                        Helper.toast(message: "error: \( errMessage ?? "error")", thisVC: self)
                        return
                    }
                    //Helper.toast(message: "Uploaded \(type)", thisVC: self)
                    self.uploadImages(typeIndex: typeIndex + 1, callback: fincallback);
  
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
        var hasPicture = false
        for type in pictureTypes{
            let imagePath = Helper.getImagePath(folder: "Show").appendingPathComponent("\(productData?.prodno ?? "")_\(type)_1.png")
            if FileManager.default.fileExists(atPath: imagePath.path) {
                hasPicture = true
                break;
            }
        }
        guard hasPicture else {
            Helper.toast(message:"Please take a image for this product", thisVC:self)
            return
        }
        var params = Helper.makeRequest()
                   params.merge(["prodno": productData?.prodno ?? "",
                                 "specdesc" : desc,
                                 "empno": UIDevice.current.identifierForVendor!.uuidString,
                   ]) { (any1, any2) -> Any in
                       any2
                   }
                   self.view.makeToastActivity(.center)
                   Alamofire.request(AppCons.SE_Server + "Sp/sp_UpProductLineMaster", method: .post, parameters: params, encoding: JSONEncoding.default)
                       .debugLog()
                       .validate(statusCode: 200..<300)
                       .responseJSON{
                           response in
                           if let error = response.result.error {
                               Helper.toast(message: Helper.getErrorMessage(response.result), thisVC: self)
                               return
                           }
                           print(response.data)
                           let value = response.result.value
                           print(value)
                           let JSON = value as! NSDictionary
                           let result = (JSON.value(forKey: "result") as! NSArray).firstObject as! NSDictionary
                           let errCode = result.value(forKey: "errCode") as? Int
                           let errMessage = result.value(forKey: "errData") as? String
                           guard errCode != -1 else{
                               Helper.toast(message: "error: \( errMessage ?? "error")", thisVC: self)
                               return
                           }
                        self.uploadImages(typeIndex: 0){
                            let productDAO = ProductDAO()
                            productDAO.create(data: self.productData!)
                            self.delegate?.onDataChange(productData: self.productData!)
                            self.navigationController?.popViewController(animated: true)
                        }
                   }
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let image512 = Helper.cropToBounds(image: image, width: 512, height: 512)
        let image110 = Helper.cropToBounds(image: image512, width: 110, height: 110)
       // mImage.image = image
      //  mImage.contentMode = .scaleToFill
        let dataPath = Helper.getImagePath(folder: "Show")
        if let data512 = image512.jpegData(compressionQuality: 1) {
            let filename = dataPath.appendingPathComponent("\(productData?.prodno ?? "")_type1.png")
            try? data512.write(to: filename)
        }
        if let data110 = image110.jpegData(compressionQuality: 1) {
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
                let image512 = Helper.cropToBounds(image: image, width: 1024, height: 1024)
                let image110 = Helper.cropToBounds(image: image512, width: 110, height: 110)
               // self?.mImage.image = image
                //self?.mImage.contentMode = .scaleToFill
                let dataPath = Helper.getImagePath(folder: "Show")
                if let data512 = image512.pngData() {
                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type1.png")
                    try? data512.write(to: filename)
                }
                if let data110 = image110.pngData() {
                    let filename = dataPath.appendingPathComponent("\(self?.productData?.prodno ?? "")_type2.png")
                    try? data110.write(to: filename)
                }
                self?.afterPickImage?()
                self?.afterPickImage = nil
                
                self?.mCollectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
            }
            
            
        }
        present(vc, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
