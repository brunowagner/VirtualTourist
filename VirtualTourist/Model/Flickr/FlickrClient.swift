//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Bruno W on 28/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class FlickrClient{
    
    typealias completionAnyObjectAndError = (AnyObject?, NSError?)->Void
    typealias completionDictionaryAndError = (AnyObject?, NSError?)->Void
    
    let defaultParametersToSearch : [String : AnyObject] = [
        Constants.Flickr.FlickrParameterKeys.APIKey : Constants.Flickr.FlickrParameterValues.APIKey as AnyObject,
        Constants.Flickr.FlickrParameterKeys.Method : Constants.Flickr.FlickrParameterValues.SearchMethod as AnyObject ,
        Constants.Flickr.FlickrParameterKeys.Format : Constants.Flickr.FlickrParameterValues.ResponseFormat as AnyObject ,
        Constants.Flickr.FlickrParameterKeys.NoJSONCallback : Constants.Flickr.FlickrParameterValues.DisableJSONCallback as AnyObject,
        Constants.Flickr.FlickrParameterKeys.PerPage : 20 as AnyObject
        ]
    
    let defaultMethod = ""
    

    func findPhotosURLByLocation(latitude: Double, longitude : Double, radius: Double, completion: @escaping (_ urls : [URL]?, _ error : NSError?)->Void){
        
//        let parameters : [String : AnyObject] = [
//            Constants.Flickr.FlickrParameterKeys.APIKey : Constants.Flickr.FlickrParameterValues.APIKey as AnyObject,
//            Constants.Flickr.FlickrParameterKeys.Method : Constants.Flickr.FlickrParameterValues.SearchMethod as AnyObject ,
//            Constants.Flickr.FlickrParameterKeys.Latitude : latitude as AnyObject ,
//            Constants.Flickr.FlickrParameterKeys.Longitude : longitude as AnyObject ,
//            Constants.Flickr.FlickrParameterKeys.Radius : radius as AnyObject ,
//            Constants.Flickr.FlickrParameterKeys.Extras : Constants.Flickr.FlickrParameterValues.MediumURL as AnyObject ,
//            Constants.Flickr.FlickrParameterKeys.Format : Constants.Flickr.FlickrParameterValues.ResponseFormat as AnyObject ,
//            Constants.Flickr.FlickrParameterKeys.NoJSONCallback : Constants.Flickr.FlickrParameterValues.DisableJSONCallback as AnyObject ,
//        ]
        
        requestToGetNumberOfPages(latitude: latitude, longitude: longitude, radius: radius) { (pages, error) in
            guard error == nil else{
                completion(nil,error)
                return
            }
            
            //select a random page
            let randomPage = Int(arc4random_uniform(pages!))
            print(randomPage)
            
            self.requestToGetPhotosUrls(latitude: latitude, longitude: longitude, radius: radius, page: randomPage, completion: { (urls, error) in
                guard error == nil else{
                    completion(nil,error)
                    return
                }
                
                completion(urls,nil)
            })
        }
        
        
    }
    
    private func requestToGetNumberOfPages(latitude: Double, longitude : Double, radius: Double, completion: @escaping (_ UInt32 : UInt32?, _ error : NSError?)->Void){

        var parameters = defaultParametersToSearch
        
        parameters[Constants.Flickr.FlickrParameterKeys.Latitude] = latitude as AnyObject
        parameters[Constants.Flickr.FlickrParameterKeys.Longitude] = longitude as AnyObject
        parameters[Constants.Flickr.FlickrParameterKeys.Radius] = radius as AnyObject
        
        
        func sendError(errorCode: Int, errorString: String){
            print(errorString)
            let userInfo = [NSLocalizedDescriptionKey : errorString]
            completion(nil, NSError(domain: "\(String(describing: self)):requestToGetNumberOfPages", code: errorCode, userInfo: userInfo))
        }
        
        let _ = HTTPTools.taskForGETMethod(defaultMethod, parameters: parameters, apiRequirements: FlickrApiRequirements.sharedInstance()) { (results, error) in
            
            guard error == nil else{
                sendError(errorCode: (error?.code)!, errorString: (error?.userInfo.description)!)
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = results![Constants.Flickr.FlickrResponseKeys.Photos] as? [String:AnyObject], let pages = photosDictionary[Constants.Flickr.FlickrResponseKeys.Pages] else {
                sendError(errorCode: ErrorTreatment.ErrorCode.No_data_or_unexpected_data_was_returned.rawValue ,errorString: "Could not get usertDictionary!")
                return
            }

            completion(pages as? UInt32,nil)
        }
        
    }
    
    private func requestToGetPhotosUrls(latitude: Double, longitude : Double, radius: Double, page : Int =  0 ,completion: @escaping (_ urls : [URL]?, _ error : NSError?)->Void){
        
        var parameters = defaultParametersToSearch
        
        parameters[Constants.Flickr.FlickrParameterKeys.Latitude] = latitude as AnyObject
        parameters[Constants.Flickr.FlickrParameterKeys.Longitude] = longitude as AnyObject
        parameters[Constants.Flickr.FlickrParameterKeys.Radius] = radius as AnyObject
        parameters[Constants.Flickr.FlickrParameterKeys.Extras] = Constants.Flickr.FlickrParameterValues.MediumURL as AnyObject
        
        if page > 0 {
            parameters[Constants.Flickr.FlickrParameterKeys.Page] = page as AnyObject
        }
        
        
        let _ = HTTPTools.taskForGETMethod(defaultMethod, parameters: parameters, apiRequirements: FlickrApiRequirements.sharedInstance()) { (results, error) in

            func sendError(errorCode: Int, errorString: String){
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completion(nil, NSError(domain: "\(String(describing: self)):requestToGetPhotosUrls", code: errorCode, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError(errorCode: (error?.code)!, errorString: (error?.userInfo.description)!)
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = results![Constants.Flickr.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.Flickr.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError(errorCode: ErrorTreatment.ErrorCode.No_data_or_unexpected_data_was_returned.rawValue, errorString: "Could not get usertDictionary!")
                return
            }
            
            var urls : [URL] = []
            
            for photo in photoArray{
                if let urlPhoto = photo[Constants.Flickr.FlickrResponseKeys.MediumURL] as? String {
                    urls.append(URL(string: urlPhoto)!)
                }
            }
            completion(urls,nil)
        }
    }
    
    
    class func sharedInstance()-> FlickrClient{
        struct Singleton{
            static let sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
