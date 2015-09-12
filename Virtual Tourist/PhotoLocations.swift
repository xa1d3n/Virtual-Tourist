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
    
    // get phtos from flickr
    static func getLocations(latitude: String, longitude: String, currPage: Int) {

        FlickrClient.sharedInstance().getPhotosForLocation(latitude, long: longitude, page: "\(currPage)") { (result, error) -> Void in
            if error == nil {
                
                if let photos = result {
                    dispatch_async(dispatch_get_main_queue(), {
                        let photosArr = photos.photoUrls.mutableCopy() as! NSMutableArray
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.photoUrls = photosArr
                        
                        self.saveToCoreData(latitude, longitude: longitude, imgUrls: photosArr)
                    })
                }
                
            }
            else {
                print("error")
            }
        }
    }
    
    // save pin & photos to core dta
    static func saveToCoreData(latitude: String, longitude: String, imgUrls: NSMutableArray) {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let context = appDel.managedObjectContext
        
        let newPin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: context) as! Pin
        
        
        
        newPin.latitude = latitude
        newPin.longitude = longitude
        
        savePhotosToCoreData(newPin, imgUrls: imgUrls)
    }
    
    // save photos to core data
    static func savePhotosToCoreData(newPin : Pin, imgUrls: NSMutableArray) {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let context = appDel.managedObjectContext
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        for url in imgUrls {
            //println(url)
            let imgUrl = url["url_m"]  as? String
            let id = url["id"] as? String
            let idNum = Int((id)!)
            // println(idNum)
            
            let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
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
                        
                        _ = UIImage(named: savePath)
                        // println(image)
                    }
                }
            }
            
        }
        
        
        
        do {
            try context.save()
        } catch {

        }
    }
    
    // remove phtos from core data
    static func removePhotosFromCoreData(pin: Pin, photos: Array<Photo>) {
            let appDel : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            for photo in photos {
                pin.removePhotosObject(photo)
                pin.willSave()
                do {
                    try appDel.managedObjectContext.save()
                } catch {
                    
                }
                
            
            }
    }
    
    // remove photos from library
    static func removePhotosFromLibrary(pin: Pin, photos: Array<Photo>) {
        var documentsDir : String?
        
        var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        if paths.count > 0 {
            documentsDir = paths[0] as? String
            for photo in photos {
                let savePath = documentsDir! + "/\(photo.id).jpg"
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(savePath)
                } catch {
                    
                }
            }
        }
    }
    
    // get photos from flickr. Used in phtoAlbum view controller
    static func getPhotos(viewCntrl: PhotoAlbumViewController, spinner: UIActivityIndicatorView) {
        
        
        FlickrClient.sharedInstance().getPhotosForLocation(viewCntrl.pin!.latitude, long: viewCntrl.pin!.longitude, page: "\(viewCntrl.currPage)") { (result, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    if let photos = result {
                        viewCntrl.photosArr = photos.photoUrls.mutableCopy() as? NSMutableArray
                        PhotoLocations.savePhotosToCoreData(viewCntrl.pin!, imgUrls: viewCntrl.photosArr!)
                        if viewCntrl.currPage <= viewCntrl.photosArr!.count {
                            viewCntrl.currPage++
                        }
                        else {
                            viewCntrl.newCollectionBtn.enabled = false
                        }
                    }
                    if viewCntrl.photosArr!.count > 0 {
                        viewCntrl.noImagesLbl.hidden = true
                        viewCntrl.collView.hidden = false
                        viewCntrl.collView.reloadData()
                        spinner.stopAnimating()
                        viewCntrl.newCollectionBtn.enabled = true
                    }
                    else {
                        viewCntrl.noImagesLbl.hidden = false
                        viewCntrl.collView.hidden = true
                        viewCntrl.newCollectionBtn.enabled = false
                    }
                })
            }
            else {
                print("error")
            }
        }
        
        
    }
    
    // get photos from core data
    static func getPhotosFromCoreData(viewCntrl: TravelLocationsMapViewController, latitude: String, longitude: String) -> Set<NSObject> {

        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        let latPred = NSPredicate(format: "latitude = %@", latitude)
        let longPred = NSPredicate(format: "longitude = %@", longitude)
        
        let compound = NSCompoundPredicate.andPredicateWithSubpredicates([latPred, longPred])
        request.predicate = compound
        
        var results = Array<Pin>()
        
        do {
            try results = viewCntrl.appDel.managedObjectContext.executeFetchRequest(request) as! [Pin]
        } catch {
            
        }
        
        viewCntrl.selectedPin = results[0]
        
        
        return viewCntrl.selectedPin!.photos
    }
}
