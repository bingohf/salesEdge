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

class SampleController: UIViewController,QRCodeReaderViewControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var mFieldBillNo: UITextField!

    @IBOutlet weak var mWebView: UIWebView!
    @IBOutlet weak var mFieldPANO: UITextField!
    
    @IBOutlet weak var mIndicator: UIActivityIndicatorView!
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr,.code39,.code128, .upce,.aztec,.code93,.dataMatrix,.ean13,.pdf417], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mWebView.loadHTMLString("Hello world", baseURL: nil)
        mIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func onMoreMenuTap(_ sender: Any) {
        let alertController = UIAlertController(title:"alert", message:"Select action",preferredStyle:UIAlertControllerStyle.actionSheet)
        let groupQRCodeAction = UIAlertAction(title:"Change Group", style:.default){
            (action: UIAlertAction!) -> Void in
           // self.scanARcode()
        }
        alertController.addAction(groupQRCodeAction)
        alertController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        self.present(alertController, animated:true,completion:nil)
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

