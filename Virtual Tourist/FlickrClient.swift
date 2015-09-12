//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/11/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import Foundation

class FlickrClient {
    
    var session : NSURLSession
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    // MARK - GET
    func taskForGetMethod(method: String, completionHandler: (result: AnyObject!, error :NSError?) -> Void ) -> NSURLSessionDataTask {
        
        var urlString : String = ""
        
        urlString = Constants.BASE_URL + method
        
        let url = NSURL(string : urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        })
        
        task!.resume()
        
        return task!
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let parsingError: NSError? = nil
        var parsedResult: AnyObject?
        do {
            try parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            
        }
        //let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }

}
