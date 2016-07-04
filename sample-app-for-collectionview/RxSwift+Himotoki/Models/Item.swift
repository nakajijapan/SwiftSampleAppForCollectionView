//
//  Item.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/07/02.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Foundation
import Himotoki

struct Item: Decodable {
    var id:Int?
    var title:String
    var url:NSURL
    var imageL:NSURL
    var createdAt:NSDate
    var user:User

    static func decode(e: Extractor) throws -> Item {
        
        return try Item(
            id:        e <|? "id",
            title:     e <| "title",
            url:       urlTranformer(e <| "url"),
            imageL:    urlTranformer(e <| "image_l"),
            createdAt: createdAtTransformer(e <| "created_at"),
            user:      e <| "user"

        )
    }
    
    private static func urlTranformer(string: String) throws -> NSURL {
        if let URL = NSURL(string: string) {
            return URL
        }
        
        throw customError("Invalid URL string: \(string)")
    }
    
    private static func createdAtTransformer(string: String) throws -> NSDate {
 
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.timeZone = NSTimeZone(abbreviation: "JST")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0900"
        
        guard let result = dateFormatter.dateFromString(string) else {
            throw customError("Invalid Date string: \(string)")
        }
        
        return result
    }
    
}