//
//  Scheculer.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/02/07.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class Scheduler {
    
    //let backgroundWorkScheduler: ImmediateSchedulerType
    let backgroundWorkScheduler: OperationQueueScheduler
    let mainScheduler: SerialDispatchQueueScheduler
    
    init() {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        mainScheduler = MainScheduler.instance
    }
    
}