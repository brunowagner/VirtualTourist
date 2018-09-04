//
//  DataTask.swift
//  OnTheMap
//
//  Created by Bruno W on 28/07/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
struct HTTPTools {
    
    static let session = URLSession.shared
    
    // MARK: GET
    static func taskForGETMethod(_ method: String, parameters: [String:AnyObject], apiRequirements : ApiRequirements, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let url = apiRequirements.parseURLFromParameters(parameters, withPathExtension: method)

        /* 2/3. Build the URL, Configure the request */
        var request = NSMutableURLRequest(url: url)
        apiRequirements.requestConfigToGET(urlRequest: &request)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            HTTPTools.treatsDataTask(data: data, response: response, error: error, apiRequirements: apiRequirements, completionHandlerForTreatsDataTask: completionHandlerForGET)
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: POST
    
    static func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, apiRequirements : ApiRequirements, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL, Configure the request */
        var request = NSMutableURLRequest(url: apiRequirements.parseURLFromParameters(parameters, withPathExtension: method))
        //var urlRequest = request as URLRequest
        apiRequirements.requestConfigToPOST(urlRequest: &request, jsonBody: jsonBody)
        
        //urlRequest = request as URLRequest
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            HTTPTools.treatsDataTask(data: data, response: response, error: error, apiRequirements: apiRequirements, completionHandlerForTreatsDataTask: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: DELETE
    
    static func taskForDeleteMethod(_ method: String, parameters: [String:AnyObject], apiRequirements : ApiRequirements, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL, Configure the request */
        var request = NSMutableURLRequest(url: apiRequirements.parseURLFromParameters(parameters, withPathExtension: method))
        apiRequirements.requestConfigToDELET(urlRequest: &request)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            HTTPTools.treatsDataTask(data: data, response: response, error: error, apiRequirements: apiRequirements, completionHandlerForTreatsDataTask: completionHandlerForDELETE)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: PUT
    static func taskForPUTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, apiRequirements : ApiRequirements, completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL, Configure the request */
        var request = NSMutableURLRequest(url: apiRequirements.parseURLFromParameters(parameters, withPathExtension: method))
        apiRequirements.requestConfigToPUT(urlRequest: &request, jsonBody: jsonBody)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            HTTPTools.treatsDataTask(data: data, response: response, error: error, apiRequirements: apiRequirements, completionHandlerForTreatsDataTask: completionHandlerForPUT)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    static func treatsDataTask (data : Data?,response: URLResponse?,error : Error?, apiRequirements : ApiRequirements, completionHandlerForTreatsDataTask: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        func sendError(errorCode: Int, errorString: String){
            print(errorString)
            let userInfo = [NSLocalizedDescriptionKey : errorString]
            completionHandlerForTreatsDataTask(nil, NSError(domain: "", code: errorCode, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            let codeError = self.getErrorCode(error: error! as NSError)
            sendError(errorCode: codeError , errorString: "There was an error with your request: \(error!)")
            return
        }

        /* GUARD: Did we get a successful response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
            sendError(errorCode: ErrorTreatment.ErrorCode.Response_statusCode_error.rawValue, errorString: "Your request returned a invalid status code!")
            return
        }
        /* GUARD: Did we get a successful 2XX response? */
        if !(statusCode >= 200 && statusCode <= 299) {
            sendError(errorCode: statusCode, errorString: "Your request returned a status code other than 2xx!")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError(errorCode: ErrorTreatment.ErrorCode.No_data_or_unexpected_data_was_returned.rawValue ,errorString: "No data was returned by the request!")
            return
        }
        
        /* 5/6. Parse the data and use the data (happens in completion handler) */
        let usefulData = apiRequirements.getValidData(data: data)
        
        //Retirado pela implementação ao ApiRequeriments
        
        self.convertDataWithCompletionHandler(usefulData, completionHandlerForConvertData: completionHandlerForTreatsDataTask)
        
    }
    
    static func getErrorCode(error : NSError) -> Int{
        return error.code
    }
    
    private static func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: ErrorTreatment.ErrorCode.Could_not_parse_the_data.rawValue, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

    static func putHTTPOnUrlString (urlString : String)->String{
        let subString = urlString.prefix(4)

        if subString != "http"{
            return "Http://\(urlString)"
        }else{
            return urlString
        }
    }
}
