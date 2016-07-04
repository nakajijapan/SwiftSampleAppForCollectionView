//
//  UnboxUser.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/07/02.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Foundation
import Unbox

struct UnboxUser: Unboxable {

    var id:Int?
    var iconName:NSURL
    var username:String

    init(unboxer: Unboxer) {
        self.id = unboxer.unbox("id")
        self.iconName = unboxer.unbox("icon_name")
        self.username = unboxer.unbox("username")
    }

    
}
