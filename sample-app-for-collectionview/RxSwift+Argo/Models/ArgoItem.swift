//
//  ArgoItem.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/07/02.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Foundation
import Argo
import Curry

struct ArgoItem: Argo.Decodable  {
    var id:Int?
    var title:String
    var url:NSURL
    var imageL:NSURL
    var createdAt:NSDate
    var user:ArgoUser

    static func decode(j: JSON) -> Decoded<ArgoItem> {
        
        return curry(ArgoItem.init)
            <^> j <|? "id"
            <*> j <| "title"
            <*> j <| "url"
            <*> j <| "image_l"
            <*> (j <| "created_at" >>-  toNSDate)
            <*> j <| "user"
    }
    

    private static func toNSDate(string: String) -> Decoded<NSDate> {
 
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.timeZone = NSTimeZone(abbreviation: "JST")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0900"
        
        let result = dateFormatter.dateFromString(string)
        return .fromOptional(result)
    }
    
}

extension NSURL: Decodable {
    public static func decode(j: JSON) -> Decoded<NSURL> {
        switch(j) {
        case let .String(s): return .fromOptional(NSURL(string: s))
        default: return .fromOptional(NSURL())
        }
    }
}
