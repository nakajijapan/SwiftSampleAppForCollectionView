//
//  CollectionViewData.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/02/07.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBlocking

class CollectionViewData:RxScrollViewDelegateProxy {
    
    var loading = false
    var currentPage = 1
    var viewController:ViewController
    
    required init(parentObject: AnyObject, viewController:ViewController) {
        self.viewController = viewController
        super.init(parentObject: parentObject)


    }

    required init(parentObject: AnyObject) {
        self.viewController = ViewController()
        super.init(parentObject: parentObject)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // bottom?
        if self.scrollView!.contentOffset.y >= (self.scrollView!.contentSize.height - self.scrollView!.bounds.size.height * 2) {
            
            let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            if self.loading == true {
                return
            }
            
            self.loading = true
            dispatch_async(q_global, {
                
                self.viewController.reloadData2(self.currentPage + 1)
                
            })
            
        }

        
    }
    
}

