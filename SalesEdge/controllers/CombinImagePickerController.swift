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
    
    var onCompleted : ((UIImage?) -> Void)?
    
    override func viewDidLoad() {
       
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
        
                button.setImage(image, for: UIControlState.normal)
                button.imageView?.contentMode = .scaleAspectFit
                
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func onTouchSave(_ sender: Any) {
    
//        var topImage = mImage1.image(for: .normal)
//         var bottomImage = mImage1.image(for: .normal)
//        var size = CGSize(width: 512, height: 512)
//        UIGraphicsBeginImageContext(size)
//        
//        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        bottomImage!.drawInRect(areaSize)
//        
//        topImage!.drawInRect(areaSize, blendMode: kCGBlendModeNormal, alpha: 0.8)
//        
//        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        onCompleted?(mImage1.image(for: .normal))
//        self.dismiss(animated: true, completion: nil)
        
        
    }
}
