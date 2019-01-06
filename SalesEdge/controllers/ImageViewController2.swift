//
//  ImageViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/2.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController2:UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var mImageView: UIImageView!
    
    var imageUrl:String? = nil
    
    override func viewDidLoad() {
        mImageView.contentMode = .scaleToFill
        mImageView.contentMode = .scaleAspectFit
        mImageView.af_setImage(
            withURL: URL(string: "\(AppCons.BASE_URL)\(imageUrl ?? "")")!,
            placeholderImage: #imageLiteral(resourceName: "default_image"),
            imageTransition: .crossDissolve(0.2)
        )
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mImageView
    }
}
