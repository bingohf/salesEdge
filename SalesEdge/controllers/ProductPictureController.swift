//
//  ProductPictureController.swift
//  SalesEdge
//
//  Created by bingo on 2020/10/2.
//  Copyright © 2020 Bin Guo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ProductPictureController: UICollectionViewController,UICollectionViewDelegateFlowLayout{
    var prodno = ""
    var mainUrl = ""
    private let pictureTypes = ["Main" , "Left" ,"Flat", "Down", "Front", "Bent", "Right"]
    override func viewDidLoad() {
//        self.view.makeToastActivity(.center)
//        loadImage(index: 1){
//            self.view.hideToastActivity()
//            self.collectionView.reloadData()
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureTypes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell :ProductCollectionViewCell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) as! ProductCollectionViewCell2
        let index = indexPath.row
        cell.image.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.06)
        cell.label.text = ProductViewController.pictureTypes[indexPath.row]
        cell.label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)

        cell.image.contentMode = .scaleToFill
        cell.image.image = nil
        let filename = Helper.getImagePath(folder: "receiver", prodno: prodno , type: pictureTypes[indexPath.row])
        print(filename.path)
        if FileManager.default.fileExists(atPath: filename.path){
           cell.image.image = UIImage(contentsOfFile: filename.path)
           cell.image.contentMode = .scaleToFill
           cell.image.contentMode = .scaleAspectFit
        }
        
        let imageUrl = getImageUrl(index: indexPath.row)
        cell.image.af_setImage(
            withURL: URL(string: "\(AppCons.SE_Server)\(imageUrl)")!,
            placeholderImage: #imageLiteral(resourceName: "default_image"),
            imageTransition: .crossDissolve(0.2)
        )
        cell.image.contentMode = .scaleAspectFill
        cell.image.clipsToBounds = true
        cell.image.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.label.frame = CGRect(x: 0, y: cell.frame.height - 20, width: cell.frame.width, height: 20)
        return cell
    }
    
    func getImageUrl(index:Int) -> String {
        var imageUrl = mainUrl
        if index > 0 {
            let type = pictureTypes[index]
            let mytaxno = Helper.getMyTaxNO()
           // let prodno = "AIMW0094-PR3GH"
            imageUrl = "spStream/SP_GET_PRODUCTImageV1?out_field=prodimage&PRODNO=\(prodno)&mytaxno=\(mytaxno)&type=\(type)"
        }
        return imageUrl
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    
    func loadImage(index:Int,callback:@escaping ()->Void)  {
        guard index < pictureTypes.count else {
            
            DispatchQueue.main.async {
                callback()
            }
            return
        }
        let type = pictureTypes[index]
        let file = Helper.getImagePath(folder: "receiver", prodno: prodno, type: type)
        guard !FileManager.default.fileExists(atPath: file.path) else {
            loadImage(index: index + 1, callback: callback)
            return
        }
        let mytaxno = Helper.getMyTaxNO()
        if let url = URL.init(string: AppCons.SE_Server + "spStream/SP_GET_PRODUCTImageV1?out_field=prodimage&PRODNO=\(prodno)&mytaxno=\(mytaxno)&type=\(type)&v1=\(Date().timeIntervalSince1970)"){
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession.init(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let reqeust = try! URLRequest.init(url: url, method: HTTPMethod.get)
            let task = session.dataTask(with: reqeust) { (d, r, e) in
                if let error = e {
                    self.loadImage(index: index + 1, callback: callback)
                    return
                }
                guard let httpResponse = r as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                    self.loadImage(index: index + 1, callback: callback)
                    return
                }
                if let data = d {
                    if data.count > 0 {
                        try? data.write(to: file)
                        Helper.setUploaded(file: file)
                    }
                }
                self.loadImage(index: index + 1, callback: callback)
            }

            task.resume()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = getImageUrl(index: indexPath.row)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ImageViewController2") as! ImageViewController2
            vc.imageUrl = url
            vc.title = prodno + "_" + pictureTypes[indexPath.row]
            show(vc, sender: nil)
        
    }
}
