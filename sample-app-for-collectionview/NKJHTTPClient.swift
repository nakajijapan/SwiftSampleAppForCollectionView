//
//  HTTPClient.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 2016/02/07.
//  Copyright © 2016年 net.nakajijapan. All rights reserved.
//

import Alamofire
import RxSwift
import Foundation

public class NKJHttpClient {
    
    private static let manager: Manager = Alamofire.Manager()
    
    public func get(url: NSURL, parameters: [String : String]?, headers: [String : String]?) -> Observable<(NSData, NSHTTPURLResponse)> {
            return action(Alamofire.Method.GET, url: url, parameters: parameters, headers: headers)
    }
    
    public func post(url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<(NSData, NSHTTPURLResponse)> {
            return action(.POST, url: url, parameters: parameters, headers: headers)
    }
    
    private func action(method: Alamofire.Method, url: NSURL, parameters: [String:String]?, headers: [String:String]?) -> Observable<(NSData, NSHTTPURLResponse)> {
            let request = NKJHttpClient.manager.request(method, url, parameters: parameters, encoding: ParameterEncoding.URL).request
            let mutableRequest = setHeader(headers, mutableRequest: request!.mutableCopy() as! NSMutableURLRequest)
            return NKJHttpClient.manager.session.rx_response(mutableRequest)
    }
    
    private func setHeader(headers: [String:String]?, mutableRequest: NSMutableURLRequest) -> NSMutableURLRequest {
        if let headers = headers {
            for (key, value) in headers {
                mutableRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        return mutableRequest
    }
    
}