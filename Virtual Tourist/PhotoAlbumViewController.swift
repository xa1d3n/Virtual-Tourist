//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/9/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import UIKit
import MapKit



class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var longitude : String!
    var latitude : String!
    var currPage = 1
    var photosFromCoreData : Array<Photo>?
    
    let appDel : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var photosArr : NSMutableArray!
    var indexPaths = [NSIndexPath]()
    
    var pin : Pin?
   
    
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!

    @IBOutlet weak var noImagesLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        HelperFunctions.setPin(self.mapView, latitude: latitude, longitude: longitude, shouldZoomIn:true)
        
        if let photos = photosFromCoreData {
        }
        else {
            getPhotos()
        }
        
    }
    
    // enable/disable buttons
    func setupButtons() {
        if self.photosArr?.count > 0 {
            self.noImagesLbl.hidden = true
            self.collView.hidden = false
            self.newCollectionBtn.enabled = true
            currPage++
        }
        else {
            self.noImagesLbl.hidden = false
            self.collView.hidden = true
            self.newCollectionBtn.enabled = false
        }
    }
    
    // delete photos from core data & documents library, get new photos from flicker, put new photos into core data
    func getPhotos() {
        
        PhotoLocations.removePhotosFromLibrary(pin!, photos: photosFromCoreData!)
        PhotoLocations.removePhotosFromCoreData(pin!, photos: photosFromCoreData!)
        photosFromCoreData?.removeAll(keepCapacity: false)
        
        newCollectionBtn.enabled = false
        
        var spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(spinner)
        spinner.startAnimating()
        
        PhotoLocations.getPhotos(self,  spinner: spinner)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var items = 0
    
        if let photosCoreData = photosFromCoreData?.count {
            if photosCoreData > 0 {
                items = photosCoreData
            }
            else if let photoCount = photosArr?.count {
                items = photoCount
            }

            
        }
       else if let photoCount = photosArr?.count {
            items = photoCount
       }
       
        if items < 1 {
            noImagesLbl.hidden = false
        }
        else {
            noImagesLbl.hidden = true
        }
        
        return items
    }
    
    // display photos from core data or retrive from flikr
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell : PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("image", forIndexPath: indexPath) as! PhotoCell
        
        if photosFromCoreData?.count > 0 {
            
        
        if let photos = photosFromCoreData {
            let photoId = photos[indexPath.row].id!
            
            var documentsDir : String?
            
            var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            
            if paths.count > 0 {
                documentsDir = paths[0] as? String
                let savePath = documentsDir! + "/\(photoId).jpg"
                var img = UIImage(named: savePath)
                cell.imageView.image = img
            }

            
            }

        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if let urlString = self.photosArr?.objectAtIndex(indexPath.row)["url_m"]  as? String {
                    let url = NSURL(string: urlString)
                    let data = NSData(contentsOfURL: url!)
                    
                    
                    let image = UIImage(data: data!)
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                     cell.imageView.image = image
                    })
                }
            })
        }
        
        return cell
    }
    
    // handle deletion
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        removeBtn.hidden = false
        newCollectionBtn.hidden = true
        
        
        var cell = collView.cellForItemAtIndexPath(indexPath)
        
        var isSelected = false
        
        var i = 0
        for index in indexPaths {
            if index == indexPath {
                indexPaths.removeAtIndex(i)
                isSelected = true
                break
            }
            i++
        }
        
        if isSelected {
            cell?.layer.borderWidth = 0.0
            if indexPaths.count < 1 {
                removeBtn.hidden = true
                newCollectionBtn.hidden = false
            }
        }
        else {
            cell?.layer.borderWidth = 2.0
            cell?.layer.borderColor = UIColor.redColor().CGColor
            indexPaths.append(indexPath)
        }
        
    }
    
    // handle new collection button click
    @IBAction func newCollection(sender: UIButton) {
        getPhotos()
    }
    
    
    // remove pictures
    @IBAction func removePictures(sender: UIButton) {
        collView.performBatchUpdates({ () -> Void in
            
            
            
            for index in self.indexPaths {
                
                if self.photosFromCoreData?.count > 0 {
                    self.deleteFromCoreData(index.row);
                }
                
                else {
                    if index.row >= self.photosArr.count {
                        self.photosArr.removeLastObject()
                    }else {
                        self.photosArr.removeObjectAtIndex(index.row)
                    }
                }
                
                
                
                
                var cell = self.collView.cellForItemAtIndexPath(index)
                cell?.layer.borderWidth = 0.0
            }
            
            self.collView.deleteItemsAtIndexPaths(self.indexPaths)
        }, completion: nil)
        
        indexPaths.removeAll(keepCapacity: false)
        
        removeBtn.hidden = true
        newCollectionBtn.hidden = false
    }

    // remove pictures from core data & documents
    func deleteFromCoreData(index: Int) {

        var delPhoto : Photo?
        if index >= photosFromCoreData!.count {
            delPhoto = photosFromCoreData?.removeLast()
            pin?.removePhotosObject(delPhoto)
            
        }else {
            delPhoto = photosFromCoreData?.removeAtIndex(index)
            pin?.removePhotosObject(delPhoto)
        }
        
        pin?.willSave()
        do {
            try appDel.managedObjectContext.save()
        } catch {
            
        }
        
        var photosToDelete = Array<Photo>()
        photosToDelete.insert(delPhoto!, atIndex: 0)
        
        PhotoLocations.removePhotosFromLibrary(pin!, photos: photosToDelete)

    }

}
