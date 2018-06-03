//
//  ImageViewController.swift
//  SalesEdge
//
//  Created by Bin Guo on 2018/6/2.
//  Copyright © 2018年 Bin Guo. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController:UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var mImageView: UIImageView!
    
    var imageUrl:URL? = nil

    override func viewDidLoad() {
        self.title = imageUrl?.lastPathComponent
        mImageView.image = UIImage(contentsOfFile: imageUrl!.path)
        mImageView.contentMode = .scaleToFill
        mImageView.contentMode = .scaleAspectFit
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mImageView
    }
}
