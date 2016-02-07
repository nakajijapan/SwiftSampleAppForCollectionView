//
//  ViewController.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 10/11/14.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView:UICollectionView!
    
    var data:NSMutableArray  = NSMutableArray()
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
                
                if data == nil {
                    print("data is none")
                    self.collectionView.reloadData()
                    return
                }
                
                var json = NSDictionary()

                do {
                    json = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: NSJSONReadingOptions.MutableContainers
                        ) as! NSDictionary
                    
                } catch {
                    print("Error")
                }
                
                let items = json.objectForKey("items") as! Array<Dictionary<String, AnyObject>> // as NSArray
                
                for item in items {
                    self.data.addObject(item)
                }
                
                self.currentPage = json.objectForKey("paginator")!.objectForKey("current_page") as! Int
                print("current page = \(self.currentPage)")
                
                self.collectionView.reloadData()
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
        let title = self.data.objectAtIndex(index).objectForKey("title") as? String
        cell.titleLabel.text = "\(index):\(title)"

        let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        let q_main: dispatch_queue_t   = dispatch_get_main_queue();
        
        
        dispatch_async(q_global, {

            let URLString               = self.data.objectAtIndex(index).objectForKey("image_l") as! String
            let imageURL: NSURL = NSURL(string: URLString)!
            let imageData = NSData(contentsOfURL: imageURL)!
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
            let q_main: dispatch_queue_t   = dispatch_get_main_queue();
            
            if self.loading == true {
                return
            }
            
            dispatch_async(q_global, {
                
                self.loading = true
                self.reloadData(self.currentPage + 1)
                
                dispatch_async(q_main, {
                    
                    self.loading = false
                    print("end")
                    
                })
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

