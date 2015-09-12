//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/11/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import Foundation
import MapKit

extension FlickrClient {
    // MARK - GET Convenience Methods
    
    func getPhotosForLocation(lat : String, long : String, page: String, completionHandler: (result: LocationPhotos?, error: NSError?) -> Void) {
        
        let methodArguments = [
            "method": Constants.GET_PHOTOS_FOR_LOCATION,
            "api_key": Constants.API_KEY,
            "extras": Constants.EXTRAS,
            "format": Constants.DATA_FORMAT,
            "nojsoncallback": Constants.NO_JSON_CALLBACK,
            "lat": lat,
            "lon": long,
            "page": page,
            "per_page": Constants.PERPAGE
        ]
        
        let method = escapedParameters(methodArguments)
        
        let task = taskForGetMethod(method, completionHandler: { (result, error) -> Void in
            if error != nil {
                print("error")
            }
            else {
                
                //println(result.valueForKey("photos") as? NSDictionary )
                if let photoInfo = result as? [NSObject: NSObject] {
                    //println(photoInfo)
                    if let photos = photoInfo["photos"] as? NSDictionary {
                        
                        let photosInfo = LocationPhotos(dictionary: photos)
                        completionHandler(result: photosInfo, error: error)
                    }
                }
            }
        })
    }
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        (!urlVars.isEmpty ? "?" : "").join(urlVars)
        
        return (!urlVars.isEmpty ? "?" : "").join(urlVars)
        
        //return (!urlVars.isEmpty ? "?" : "") + join("&", elements: urlVars)
      //  return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}