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
    var photos : LocationPhotos!
    
    
   /* static func getLocations()  {
        FlickrClient.sharedInstance().getPhotosForLocation(lat: String, long: String) { (result, error) -> Void in
            if let photos = result {
                dispatch_async(dispatch_get_main_queue(), {
                   
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    //println(photos.perpage)
                    appDelegate.photosInfo = photos
                   // println(appDelegate.photosInfo.perpage)

                })
            }
            else {
                if error != nil {
                println("no phtos:(")
                }
            }
        }
        
    } */
}
