//
//  FirstViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/1/20.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import QRCodeReader
import AVFoundation
import Alamofire

class SampleController: UIViewController,QRCodeReaderViewControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UIWebViewDelegate{

    @IBOutlet weak var mStateBarItem: UIBarButtonItem!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mFieldBillNo: UITextField!

    @IBOutlet weak var mWebView: UIWebView!
    @IBOutlet weak var mFieldPANO: UITextField!
    @IBOutlet weak var mIndicator: UIActivityIndicatorView!
    let baseUrl = "http://ledwayvip.cloudapp.net:8080/datasnap/rest/TLwDataModule/"
    var menus = [NSDictionary]()
    var mMode = "Check"
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr,.code39,.code128, .upce,.aztec,.code93,.dataMatrix,.ean13,.pdf417], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    func pdaGuid() -> String {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString;
        let deviceName = UIDevice.current.modelName
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyyMMdd'T'HHmmss.S"
        let timeStamp = dformatter.string(from: Date.init())
        var language = Locale.preferredLanguages.first!
        var languageArr = language.components(separatedBy: "-")
        while languageArr.count > 2 {
            languageArr.remove(at: 1)
        }
        language = languageArr.joined(separator: "_")
        return "\(deviceId)-\(deviceName)-LEDWAY-\(timeStamp)~\(language)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mWebView.loadHTMLString(pdaGuid(), baseURL: nil)
        mIndicator.startAnimating()
        loadMenus()
        queryBill(mode:"Hello")
        mStateBarItem.title = ""
        showState()
    }
    
    func loadMenus() {
        let parameters: [String: Any] = [
            "line" : "01",
            "reader" : "01",
            "MyTaxNo" : "",
            "pdaGuid": pdaGuid()
        ]
        Alamofire.request(baseUrl + "Sp/Sp_GetScanMasterMenu", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .debugLog()
            .responseJSON{
                response in
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    let array = JSON.value(forKey: "result") as! NSArray
                    let jsonString = (array.firstObject as! NSDictionary).value(forKey: "memotext") as! String
                    let menus = self.convertToArray(text: jsonString);
                    self.menus = menus as! [NSDictionary]
                    self.showState()
                }
                
        }
    }

    func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])  as? [Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func showState() {
        for item in menus {
            let text = item.value(forKey: "menu_name") as! String
            let mode = item.value(forKey: "menu_Label_Eng") as! String
            if(mode == mMode){
                mStateBarItem.title = text
                break;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {	
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryBill()  {
        queryBill(mode:mMode)
    }
    

    
    func queryBill(mode:String) {
        let parameters: [String: Any] = [
            "line" : "01",
            "reader" : "01",
            "billNo": "",
            "MyTaxNo" : "",
            "pdaGuid": pdaGuid(),
            "type" : mode
        ]
        Alamofire.request(baseUrl + "Sp/sp_getBill", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .debugLog()
            .responseJSON{
                response in
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    let array = JSON.value(forKey: "result") as! NSArray
                    let html = (array.firstObject as! NSDictionary).value(forKey: "memotext") as! String
                    print(html)
                    self.mWebView.loadHTMLString(html, baseURL: nil)
                }
                
        }
    }
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
     //   image = Helper.cropToBounds(image:image, width:512, height:512)
      //  image = Helper.resizeImage(image:image, targetSize: CGSize(width: 512, height: 512))
        mImageView.image = image
    }
    
    @IBAction func onPAQRCodeClick(_ sender: Any) {
        scanQRCode(){qrcodeResult in
            self.mFieldPANO.text = qrcodeResult?.value
        }
    }
    
    @IBAction func onBillQrCodeClick(_ sender: Any) {
        scanQRCode(){qrcodeResult in
            self.mFieldBillNo.text = qrcodeResult?.value
        }
    }
    
    @IBAction func onBtnTakePhotoClick(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func onMoreMenuTap(_ sender: Any) {
        loadMenus()
        let alertController = UIAlertController(title:nil, message:nil,preferredStyle:UIAlertControllerStyle.actionSheet)
        let groupQRCodeAction = UIAlertAction(title:"Change Group", style:.default){
            (action: UIAlertAction!) -> Void in
           // self.scanARcode()
        }
        alertController.addAction(groupQRCodeAction)
        
        for item in menus {
            let text = item.value(forKey: "menu_name") as! String
            let mode = item.value(forKey: "menu_Label_Eng") as! String
            let modeAction = UIAlertAction(title:text, style:.default){
                  (action: UIAlertAction!) -> Void in
                self.changeMode(mode: mode)
            }
            alertController.addAction(modeAction)
        }
        alertController.addAction(UIAlertAction(title:"Cancel", style:.cancel){
            (action: UIAlertAction!) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        self.present(alertController, animated:true){
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    @objc func alertControllerBackgroundTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func changeMode(mode:String)  {
        self.mMode = mode
        showState()
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            // Open links in Safari
            guard let url = request.url else { return true }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // openURL(_:) is deprecated in iOS 10+.
                UIApplication.shared.openURL(url)
            }
            return false
        default:
            // Handle other navigation types...
            return true
        }
    }
    func scanQRCode(callback: @escaping (QRCodeReaderResult?) -> Void){
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = callback
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
 
    }
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mFieldPANO || textField == mFieldBillNo{
            textField.resignFirstResponder()
            return true
        }
        return false
    }
}




extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}
