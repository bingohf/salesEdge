//
//  QRScannerViewController.swift
//  QRScanner
//
//  Created by Bin Guo on 2018/5/12.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


protocol QRCodeScannerDelegate {
    func onReceive(qrcode: String)
}

class QRCodeScannerViewController :UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    open var delegate : QRCodeScannerDelegate?
    
    @IBOutlet weak var mBtnCancel: UIButton!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    let supportedBarCodes = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.code128,AVMetadataObject.ObjectType.code39,AVMetadataObject.ObjectType.code39,AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8,AVMetadataObject.ObjectType.aztec]
    
    override func viewDidLoad() {
        // 取得 AVCaptureDevice 類別的實體來初始化一個device物件，並提供video
        // 作為媒體型態參數
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // 使用前面的 device 物件取得 AVCaptureDeviceInput 類別的實體
        do {
            let input = try AVCaptureDeviceInput.init(device: captureDevice!)
            // 初始化 captureSession 物件
            captureSession = AVCaptureSession()
            // 在capture session 設定輸入裝置
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            // 將訊息標籤移到最上層視圖
            view.bringSubview(toFront: mBtnCancel)
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        }  catch{
            print(error)
            return
        }
        
        
    }
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            //    messageLabel.text = "No QR code is detected"
            return
        }
        
        // 取得元資料（metadata）物件
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            //倘若發現的原資料與 QR code 原資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as
                AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            if metadataObj.stringValue != nil {
                //  messageLabel.text = metadataObj.stringValue
                print(metadataObj.stringValue)
                delegate?.onReceive(qrcode: metadataObj.stringValue!)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func onCancelTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
