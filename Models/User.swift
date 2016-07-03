//
//  User.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/07/02.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Foundation
import Himotoki

struct User: Decodable {

    var id:Int?
    var iconName:NSURL
    var username:String

    static func decode(e: Extractor) throws -> User {
        
        return try User(
            id:        e <|? "id",
            iconName:  urlTranformer(e <| "icon_name"),
            username:  e <| "username"
            
        )
    }
    
    private static func urlTranformer(string: String) throws -> NSURL {
        if let URL = NSURL(string: string) {
            return URL
        }
        
        throw customError("Invalid URL string: \(string)")
    }
}