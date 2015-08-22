//
//  PhotoLocations.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/17/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import Foundation
import UIKit

struct PhotoLocations {
    
   /* static func getLocations(latitude: String, longitude: String, currPage: Int) -> NSMutableArray {
        var photosArr : NSMutableArray!
        FlickrClient.sharedInstance().getPhotosForLocation(latitude, long: longitude, page: "\(currPage)") { (result, error) -> Void in
            if error == nil {
                    
                    if let photos = result {
                        photosArr = photos.photoUrls.mutableCopy() as! NSMutableArray
                    }

            }
            else {
                println("error")
            }
        }
        return photosArr
    } */
    
    static func getLocations(latitude: String, longitude: String, currPage: Int) {

        FlickrClient.sharedInstance().getPhotosForLocation(latitude, long: longitude, page: "\(currPage)") { (result, error) -> Void in
            if error == nil {
                
                if let photos = result {
                    dispatch_async(dispatch_get_main_queue(), {
                    var photosArr = photos.photoUrls.mutableCopy() as! NSMutableArray
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.photoUrls = photosArr
                    })
                }
                
            }
            else {
                println("error")
            }
        }
    }
}
