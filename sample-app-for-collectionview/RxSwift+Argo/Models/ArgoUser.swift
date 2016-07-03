//
//  ArgoUser.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/07/02.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Foundation
import Argo
import Curry

struct ArgoUser: Decodable {

    var id:Int?
    var iconName:NSURL
    var username:String

    
    static func decode(j: JSON) -> Decoded<ArgoUser> {
        
        return curry(ArgoUser.init)
            <^> j <|? "id"
            <*> j <| "icon_name"
            <*> j <| "username"
    }
    

}
