//
//  UnboxItem.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/07/02.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Foundation
import Unbox

struct UnboxItem: Unboxable {
    var id:Int?
    var title:String
    var url:NSURL
    var imageL:NSURL
    var createdAt:NSDate
    var user:UnboxUser

    
    init(unboxer: Unboxer) {
        self.id = unboxer.unbox("id")
        self.title = unboxer.unbox("title")
        self.url = unboxer.unbox("url")
        self.imageL = unboxer.unbox("image_l")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.timeZone = NSTimeZone(abbreviation: "JST")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0900"
        self.createdAt = unboxer.unbox("created_at", formatter: dateFormatter)
        
        self.user = unboxer.unbox("user")
    }
    

}
