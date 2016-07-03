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
import Himotoki


class ViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet var collectionView:UICollectionView!
    
    var items = Variable<[Item]>([])
    var loading:Bool         = false
    var currentPage:Int      = 1
    let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.rx_itemSelected.subscribeNext { (indexPath) -> Void in
            print("selected \(indexPath)")
        }.addDisposableTo(disposeBag)
        

        self.items.asObservable().bindTo(self.collectionView.rx_itemsWithCellIdentifier("CollectionViewCell")) { (row, object, cell: CollectionViewCell) in

            //print("row(\(row), object(\(object)) indexPath(\(cell)))")
            
            cell.mainImageView.image = nil
            cell.titleLabel.text = "\(index):\(object.title)"

            
            let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            let q_main: dispatch_queue_t   = dispatch_get_main_queue();
            

            dispatch_async(q_global, {
                
                guard let imageData = NSData(contentsOfURL: object.imageL) else {
                    print("画像データがない")
                    return
                }
                
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

                let jsonItems = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                let arrayItems = jsonItems["items"] as! [AnyObject]

                let _ = arrayItems.map({
                    let item = try! Item.decodeValue($0)
                    self.items.value.append(item)
                })

                self.currentPage = jsonItems["paginator"]!["current_page"] as! Int
                print("current page = \(self.currentPage)")
                
                self.collectionView.reloadData()
                self.loading = false
                
                }, onError: { (e) -> Void in
                    print(e)
                }, onCompleted: { () -> Void in
                    print("completed")
            }).addDisposableTo(disposeBag)
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

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    
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
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let side = (self.view.frame.size.width - 8 * 3) / 2.0
        return CGSizeMake(side, side)
        
    }

}
