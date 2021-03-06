//
//  NormalCollectionViewController.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/02/13.
//  Copyright © 2016 net.nakajijapan. All rights reserved.
//

import UIKit
import SwiftyJSON

class NormalCollectionViewController: UIViewController {

    @IBOutlet var collectionView:UICollectionView!
    
    typealias ItemModel = Dictionary<String, AnyObject>
    var data  = [ItemModel]()
    var loading:Bool         = false
    var currentPage:Int      = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData(1)
    }
    
    func reloadData(page: Int) {
        
        let URL     = NSURL(string:"http://frustration.me/api/public_timeline?page=\(page)")!
        let request = NSURLRequest(URL: URL)
        
        NSURLConnection.sendAsynchronousRequest(
            request,
            queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
                
                let jsonItems = JSON(data: data!)
                
                for item:JSON in jsonItems["items"].array! {
                    self.data.append(item.dictionaryObject!)
                }
                
                self.currentPage = jsonItems["paginator"]["current_page"].int!
                print("current page = \(self.currentPage)")
                
                self.collectionView.reloadData()
                
                self.loading = false
                
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.data.count / 2
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("SELECTED index: \(indexPath.section * 2 + indexPath.row)")
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "CollectionViewCell",
            forIndexPath: indexPath
            ) as! CollectionViewCell
        
        
        let index = indexPath.section * 2 + indexPath.row
        
        cell.mainImageView.image = nil
        let title = self.data[index]["title"] as? String
        cell.titleLabel.text = "\(index):\(title)"
        
        let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        let q_main: dispatch_queue_t   = dispatch_get_main_queue();
        
        
        dispatch_async(q_global, {
            
            let URLString = self.data[index]["image_l"] as! String
            let imageURL: NSURL = NSURL(string: URLString)!
            
            guard let imageData = NSData(contentsOfURL: imageURL) else {
                return
            }
            
            let image = self.resizeImage(UIImage(data: imageData)!, rect: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
            
            dispatch_async(q_main, {
                cell.mainImageView.image = image
            })
            
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let side = (self.view.frame.size.width - 8 * 3) / 2.0
        return CGSizeMake(side, side)
        
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // bottom?
        if self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height * 2) {
            
            let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            if self.loading == true {
                return
            }
            
            self.loading = true
            dispatch_async(q_global, {
                
                self.reloadData(self.currentPage + 1)
                
            })
            
        }
    }
    
    // MARK: - Private
    private func resizeImage(image: UIImage, rect: CGRect) -> UIImage {
        
        UIGraphicsBeginImageContext(rect.size);
        let resizedRect = CGRect(x: 0, y: 0, width: rect.size.width, height: image.size.height * (rect.size.width / image.size.width))
        image.drawInRect(resizedRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return resizedImage
    }
}
