//
//  CombinImagePicker.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/23.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import ALCameraViewController

class CombinImagePickerViewController:UIViewController{
    @IBOutlet weak var mImage1: UIButton!
    @IBOutlet weak var mImage2: UIButton!
    
    @IBOutlet weak var mActionSave: UIBarButtonItem!
    var onCompleted : ((UIImage?) -> Void)?
    
    override func viewDidLoad() {
       mActionSave.isEnabled = false
    }

    @IBAction func mOnImage1Touch(_ sender: Any) {
        pickImage(button: sender as! UIButton)
    }
    
    @IBAction func mOnImage2Touch(_ sender: Any) {
        pickImage(button: sender as! UIButton)
    }

    
    func pickImage(button :UIButton) {
        
        let croppingParmaters = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width:60,height:60))
        let cameraViewController = CameraViewController(croppingParameters: croppingParmaters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true)
        { [weak self] image, asset in
            if let image = image {
                self?.mActionSave.isEnabled = true
                button.setImage(image, for: UIControlState.normal)
                button.imageView?.contentMode = .scaleAspectFit
                
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func onTouchSave(_ sender: Any) {
        let width:CGFloat = 512
        let height:CGFloat = 512
        var imageSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        var image1 = mImage1.image(for: .normal)
        var image2 = mImage2.image(for: .normal)
        if image1 != nil && image2 != nil{
            if let  image = image1{
                let size = image.size
                let rate = min(width / size.width, height / size.height / 2)
                let newSize = CGSize(width: rate * size.width, height: rate * size.height)
                let x = (width - newSize.width) / 2
                let y = (height / 2 - newSize.height)
                image.draw(in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
                
            }
            if let  image = image2{
                let size = image.size
                let rate = min(width / size.width, height / size.height / 2)
                let newSize = CGSize(width: rate * size.width, height: rate * size.height)
                let x = (width - newSize.width) / 2
                let y =  height / 2
                image.draw(in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
            }
        }else{
            if let image = image1 ?? image2 {
                let size = image.size
                let rate = max(width / size.width, height / size.height)
                let newSize = CGSize(width: rate * size.width, height: rate * size.height)
                let x = (width - newSize.width) / 2
                let y = (height - newSize.height) / 2
                image.draw(in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
                
            }
        }

 
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        self.dismiss(animated: true, completion: nil)
        onCompleted?(newImage)
        
        
    }
    
    @IBAction func mOnCancelTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
