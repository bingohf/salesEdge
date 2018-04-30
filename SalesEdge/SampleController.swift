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
import Toast_Swift

class SampleController: UIViewController,QRCodeReaderViewControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UIWebViewDelegate{
    
    @IBOutlet weak var mStateBarItem: UIBarButtonItem!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mFieldBillNo: UITextField!
    
    @IBOutlet weak var mWebView: UIWebView!
    @IBOutlet weak var mFieldPANO: UITextField!

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
        //mWebView.loadHTMLString(pdaGuid(), baseURL: nil)
        loadMenus()
        queryBill(mode:"Hello")
        mStateBarItem.title = ""
        showState()
        settingChange()
        //self.view.makeToastActivity(.center)

    }
    
    func makeRequest() -> [String : Any] {
        let line = UserDefaults.standard.object(forKey: "line") as! String?
        let myTaxNo = UserDefaults.standard.object(forKey: "myTaxNo") as! String?
        return [
            "line" : "\(line ?? "01")",
            "reader" : "01",
            "MyTaxNo" : "\(myTaxNo ?? "")",
            "pdaGuid": pdaGuid()
        ]
    }
    
    func loadMenus() {
        let parameters = makeRequest()
        Alamofire.request(AppCons.BASE_URL + "Sp/Sp_GetScanMasterMenu", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .debugLog()
            .validate(statusCode: 200..<300)
            .responseJSON{
                response in
                if let error = response.result.error {
                    self.toast(message: Helper.getErrorMessage(response.result))
                    return
                }
                let value = response.result.value
                let JSON = value as! NSDictionary
                let array = JSON.value(forKey: "result") as! NSArray
                let jsonString = (array.firstObject as! NSDictionary).value(forKey: "memotext") as! String
                let menus = self.convertToArray(text: jsonString);
                self.menus = menus as! [NSDictionary]
                self.showState()
                
        }
    }
    
    func toast(message:String) {
        var vc:UIViewController? = self
        while ((vc?.parent) != nil)  {
            vc = vc?.parent
        }
        if let vc = vc {
            vc.view.makeToast(message)
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
    
    func queryBill( billNo :String = "")  {
        queryBill(mode:mMode, billNo: billNo)
    }
    
    
    
    func queryBill(mode:String, billNo :String = "", image : UIImage? = nil) {
        var apiPath = "Sp/sp_getBill"
        var param = ["type" : mode, "billNo" :billNo]
        if let image = image {
            apiPath = "Sp/sp_getBill_Photo"
            let image1 = Helper.cropToBounds(image:image, width:512, height:512)
            let image2 = Helper.cropToBounds(image:image1, width:128, height:128)
            let imageData1:NSData = UIImagePNGRepresentation(image1)! as NSData
            let imageData2:NSData = UIImagePNGRepresentation(image2)! as NSData
            
            let strBase641 = imageData1.base64EncodedString(options: .lineLength64Characters)
            let strBase642 = imageData2.base64EncodedString(options: .lineLength64Characters)
            
            param.merge(["graphic":strBase641, "graphic2": strBase642]){ (current, _) in current }
        }
        webViewRequest(apiPath: apiPath, params: param)
    }
    
   
    func queryDetail() {
        let billNo = mFieldBillNo.text ?? ""
        let detailNo = mFieldPANO.text ?? ""
        webViewRequest(apiPath: "Sp/sp_getDetail", params: ["type" : mMode, "billNo" :billNo, "detailNo" : detailNo])
    }
    
    func webViewRequest(apiPath:String, params:[String : Any])  {
        let view = self.view
        view?.makeToastActivity(.center)
        let parameters: [String: Any] = makeRequest().merging(params) { (current, _) in current }
        Alamofire.request(AppCons.BASE_URL + apiPath, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .debugLog()
            .responseJSON{
                response in
                self.showResponse(response: response)
                
        }
    }
    
    func showResponse(response : DataResponse<Any>)  {
        view?.hideToastActivity()
        guard case let  .success(value) = response.result else{
            if case let .failure(error) = response.result {
                if let error = error as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                } else if let error = error as? URLError {
                    print("URLError occurred: \(error.localizedDescription)")
                } else {
                    print("Unknown error: \(error)")
                }
            }
            return
        }
        
        
        if let result = response.result.value {
            let JSON = result as! NSDictionary
            let array = JSON.value(forKey: "result") as! NSArray
            var html = (array.firstObject as! NSDictionary).value(forKey: "memotext") as! String
            do {
                let regex = try NSRegularExpression(pattern: "^!+")
                if let result = regex.firstMatch(in: html, options: [],
                                                 range: NSRange(html.startIndex..., in: html)){
                    let str = html
                    let index = str.index(str.startIndex, offsetBy: result.range.length + 1)
                    let mySubstring = str[index...]
                    html = String(mySubstring)
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.toast(message: html)
                    
                }
            }
            catch let error{
                
            }
            
            self.mWebView.loadHTMLString(html, baseURL: nil)
            
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        queryBill(mode:mMode, billNo: mFieldBillNo.text ?? "", image:image)
    }
    
    @IBAction func onPAQRCodeClick(_ sender: Any) {
        scanQRCode(){qrcodeResult in
            if let text = qrcodeResult?.value {
                self.mFieldPANO.text = qrcodeResult?.value
                self.queryDetail()
            }
        }
    }
    
    @IBAction func onBillQrCodeClick(_ sender: Any) {
        scanQRCode(){qrcodeResult in
            if let text = qrcodeResult?.value {
                self.mFieldBillNo.text = qrcodeResult?.value
                self.queryBill(billNo: self.mFieldBillNo.text ?? "")
            }

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
        let groupQRCodeAction = UIAlertAction(title:NSLocalizedString("Change Group", comment:""), style:.default){
            (action: UIAlertAction!) -> Void in
                        self.scanQRCode(){qrcodeResult in
                            if let qrcode = qrcodeResult?.value {
                                self.receiveGroup(group: qrcode)
                            }
                        }
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
        if let text = textField.text {
            textField.resignFirstResponder()
            if textField == mFieldBillNo {
                self.queryBill(billNo: text)
            } else if textField == mFieldPANO {
                self.queryDetail()
            }
            return true
        }
        return false
    }
    
    func settingChange() {
        let preferences = UserDefaults.standard
        if let line = preferences.object(forKey: "line") as! String?, let myTaxNo = preferences.object(forKey: "myTaxNo") as! String? {
            settingChange(line: line, myTaxNo: myTaxNo)
        }
        
    }
    
    func settingChange(line:String?, myTaxNo:String?) {
        let preferences = UserDefaults.standard
        self.title = "Scan Master (\(myTaxNo ?? ""))"
        preferences.set(myTaxNo, forKey: "myTaxNo")
        preferences.set(line, forKey: "line")
        preferences.synchronize()
    }
    
    func receiveGroup(group:String) {
        let parameters = [
            "macNo" : UIDevice.current.identifierForVendor!.uuidString
        ]
        
        Alamofire.request(AppCons.BASE_URL + "group/\(group)", method: .put, parameters: parameters, encoding: JSONEncoding.default)
            .debugLog()
            .responseJSON{
                response in
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    if let array = JSON.value(forKey: "result") as! NSArray?{
                        if let result = array.firstObject as! NSDictionary? {
                            if let error = result["error"] as! String? {
                                self.toast(message: error)
                                return
                            }
                            if let line = result["line"] as! String?, let myTaxNo = result["myTaxNo"] as! String? {
                                self.settingChange(line:line, myTaxNo: myTaxNo)
                            }
                        }
                    }
                    
                }
                
        }
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
