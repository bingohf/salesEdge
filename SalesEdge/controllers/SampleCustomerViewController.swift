//
//  SampleCustomerViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/10.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import  XLPagerTabStrip
import ALCameraViewController

class SampleCustomerViewController:XLPagerItemViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,Form {
    var sampleData:MySampleData? = nil
    @IBOutlet weak var mImage: UIImageView!
    
    @IBOutlet weak var mTxtCustomer: UITextView!
    override func viewDidLoad() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("Sample").appendingPathComponent("\(sampleData?.sampleId ?? "")_type1.png")
        do{
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath.path){
                mImage.image = UIImage(contentsOfFile: filePath.path)
                mImage.contentMode = .scaleToFill
                mImage.contentMode = .scaleAspectFit
            }else{
                mImage.image = #imageLiteral(resourceName: "ic_photo_camera")
            }
            
        }catch{
            print(error)
        }
    }
    
    @IBAction func onTapGestureTouch(_ sender: Any) {
        if let guesture = sender as? UITapGestureRecognizer, let sampleId = sampleData?.sampleId {
            if guesture.view === mImage {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CombinImagePickerViewController") as! CombinImagePickerViewController
                present(vc, animated: true, completion: nil)
                vc.onCompleted = {[weak self]image in
                    self?.mImage.image = image
                    
                }
                //                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                //                let filePath = documentsDirectory.appendingPathComponent("Sample").appendingPathComponent("\(sampleId)_type1.png")
                //                do{
                //                    let fileManager = FileManager.default
                //                    if fileManager.fileExists(atPath: filePath.path){
                //                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //                        let vc = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                //                        vc.imageUrl = Helper.getImagePath(folder: "Sample").appendingPathComponent("\(sampleId)_type1.png")
                //                        show(vc, sender: sender)
                //                    }else{
                //                        let imagePicker = UIImagePickerController()
                //                        imagePicker.delegate = self
                //                        imagePicker.sourceType = .camera
                //                        present(imagePicker, animated: true, completion: nil)
                //
                //
                //                    }
                //
                //                }catch{
                //                    print(error)
                //                }
                
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
        let dataPath = Helper.getImagePath(folder: "Sample")
        if let data512 = UIImagePNGRepresentation(image512) {
            let filename = dataPath.appendingPathComponent("\(sampleData?.sampleId ?? "")_type1.png")
            try? data512.write(to: filename)
        }
        if let data110 = UIImagePNGRepresentation(image110) {
            let filename = dataPath.appendingPathComponent("\(sampleData?.sampleId ?? "")_type2.png")
            try? data110.write(to: filename)
        }
    }
    
    func save() -> Bool {
        sampleData?.customer = mTxtCustomer.text
        return true
    }
}
