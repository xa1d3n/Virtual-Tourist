//
//  PhotoLocations.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/17/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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
                        
                        self.saveToCoreData(latitude, longitude: longitude, imgUrls: photosArr)
                    })
                }
                
            }
            else {
                println("error")
            }
        }
    }
    
    static func saveToCoreData(latitude: String, longitude: String, imgUrls: NSMutableArray) {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let context = appDel.managedObjectContext
        
        var newPin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: context!) as! Pin
        
        
        
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        for url in imgUrls {
            //println(url)
            let imgUrl = url["url_m"]  as? String
            var id = url["id"] as? String
            var idNum = id?.toInt()
           // println(idNum)
            
            let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context!) as! Photo
            newPhoto.url = imgUrl
            newPhoto.id = idNum
            newPin.addPhotosObject(newPhoto)
            
            if let url = NSURL(string: imgUrl!) {
                if let data = NSData(contentsOfURL: url){
                    
                    var documentsDir : String?
                    
                    var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                    
                    if paths.count > 0 {
                        documentsDir = paths[0] as? String
                        
                        let savePath = documentsDir! + "/\(idNum!).jpg"
                        NSFileManager.defaultManager().createFileAtPath(savePath, contents: data, attributes: nil)
                        
                        var image = UIImage(named: savePath)
                       // println(image)
                    }
                }
            }
            
        }
        
        newPin.latitude = latitude
        newPin.longitude = longitude
        
        context?.save(nil)
    }
}
