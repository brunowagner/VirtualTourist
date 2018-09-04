//
//  FlickrApiRequirements.swift
//  VirtualTourist
//
//  Created by Bruno W on 28/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class FlickrApiRequirements: ApiRequirements {
    func getUrlScheme() -> String {
        return Constants.Flickr.FlickrUrl.APIScheme
    }
    
    func getUrlHost() -> String {
        return Constants.Flickr.FlickrUrl.APIHost
    }
    
    func getUrlPath() -> String {
        return Constants.Flickr.FlickrUrl.APIPath
    }
    
    
    func requestConfigToGET(urlRequest: inout NSMutableURLRequest) {
        urlRequest.httpMethod = "GET"
    }
    
    func requestConfigToPOST(urlRequest: inout NSMutableURLRequest, jsonBody: String?) {
        urlRequest.httpMethod = "POST"
    }
    
    func requestConfigToPUT(urlRequest: inout NSMutableURLRequest, jsonBody: String?) {
        urlRequest.httpMethod = "PUT"
    }
    
    func requestConfigToDELET(urlRequest: inout NSMutableURLRequest) {
        urlRequest.httpMethod = "DELETE"
    }
    
    func getValidData(data: Data) -> Data {
        return data
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrApiRequirements {
        struct Singleton {
            static var sharedInstance = FlickrApiRequirements()
        }
        return Singleton.sharedInstance
    }
}
