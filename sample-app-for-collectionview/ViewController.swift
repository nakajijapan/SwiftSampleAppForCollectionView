//
//  ViewController.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 10/11/14.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBlocking
import SwiftyJSON

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView:UICollectionView!
    
    typealias ItemModel = Dictionary<String, AnyObject>
    var data = Variable<[ItemModel]>([])
    var loading:Bool         = false
    var currentPage:Int      = 1

    let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.rx_itemSelected.subscribeNext { (indexPath) -> Void in
            print("selected \(indexPath)")
        }.addDisposableTo(disposeBag)
        

        self.data.asObservable().bindTo(self.collectionView.rx_itemsWithCellIdentifier("CollectionViewCell")) { (row, object, cell: CollectionViewCell) in

            //print("row(\(row), object(\(object)) indexPath(\(cell)))")
            
            cell.mainImageView.image = nil
            let title = object["title"] as? String
            cell.titleLabel.text = "\(index):\(title)"

            
            let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            let q_main: dispatch_queue_t   = dispatch_get_main_queue();
            

            dispatch_async(q_global, {
                
                let URLString = object["image_l"] as! String
                let imageURL: NSURL = NSURL(string: URLString)!
                let imageData = NSData(contentsOfURL: imageURL)!
                let image = self.resizeImage(UIImage(data: imageData)!, rect: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
                
                dispatch_async(q_main, {
                    cell.mainImageView.image = image
                })
                
            })

            
        }.addDisposableTo(disposeBag)
        
       
        self.reloadData(1)
    }
    func reloadData(page: Int) {
        let scheduler = Scheduler()
        let client = NKJHttpClient()
        client.get(NSURL(string: "http://frustration.me/api/public_timeline")!, parameters: ["page": "\(page)"], headers: nil)
            .observeOn(scheduler.backgroundWorkScheduler)
            .observeOn(scheduler.mainScheduler)
            .subscribe(onNext: { (data, response) -> Void in
                let jsonItems = JSON(data: data)
                
                for item:JSON in jsonItems["items"].array! {
                    self.data.value.append(item.dictionaryObject!)
                }
                
                self.currentPage = jsonItems["paginator"]["current_page"].int!
                print("current page = \(self.currentPage)")
                
                self.collectionView.reloadData()
                
                self.loading = false

                
                }, onError: { (e) -> Void in
                    print(e)
                }, onCompleted: { () -> Void in
                    print("completed")
            }).addDisposableTo(disposeBag)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
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

