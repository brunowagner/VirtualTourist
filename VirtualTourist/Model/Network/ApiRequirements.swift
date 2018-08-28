//
//  File.swift
//  OnTheMap
//
//  Created by Bruno W on 28/07/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
protocol ApiRequirements {
    
    func requestConfigToGET ( urlRequest : inout NSMutableURLRequest)
    
    func requestConfigToPOST ( urlRequest : inout NSMutableURLRequest, jsonBody : String?)
    
    func requestConfigToPUT ( urlRequest : inout NSMutableURLRequest, jsonBody : String?)
    
    func requestConfigToDELET ( urlRequest : inout NSMutableURLRequest)
    
    func getValidData (data : Data) -> Data
    
    func getUrlScheme() -> String
    
    func getUrlHost() -> String
    
    func getUrlPath() -> String
    

}

extension ApiRequirements{
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.range(of: "<\(key)>") != nil {
            return method.replacingOccurrences(of: "<\(key)>", with: value)
        } else {
            return nil
        }
    }
    
    // create a URL from parameters
    func parseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = getUrlScheme()
        components.host = getUrlHost()
        components.path = getUrlPath() + (withPathExtension ?? "")
        
        if parameters.count > 0 {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        //MARK : Block to escape colon (:)
        
        //get Url created
        let strUrl : NSString = (components.url?.absoluteString as NSString?)!
        // define range`s limit
        let limitRange =  strUrl.length - 10
        // change ":" to "%3A" on queryIten (escaping colon)
        let strURLEscapedColon =  strUrl.replacingOccurrences(of: ":", with: "%3A", options: .caseInsensitive, range: NSMakeRange(10, limitRange))
        
        let urlTotalEscaped = URL(string: strURLEscapedColon)
        
        return urlTotalEscaped!
    }
    
    
}
