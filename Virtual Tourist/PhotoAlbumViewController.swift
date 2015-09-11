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
    
    //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var longitude : String!
    var latitude : String!
    var currPage = 1
    var photosFromCoreData : Set<NSObject>?
    
    var photosArr : NSMutableArray!
    var indexPaths = [NSIndexPath]()
   
    
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
        
       // setPin()
        HelperFunctions.setPin(self.mapView, latitude: latitude, longitude: longitude, shouldZoomIn:true)
        
        if let photos = photosFromCoreData {
           // getPhotosFromCoreData(photos)
        }
        else {
            getPhotos()
        }
        //self.setupButtons()
        
    }
    
    func getPhotosFromCoreData(photos: Set<NSObject>) {
        for photo in photos {
            if let photo = photo as? Photo {
                var documentsDir : String?
                
                var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                
                if paths.count > 0 {
                    documentsDir = paths[0] as? String
                    
                    let savePath = documentsDir! + "/\(photo.id).jpg"
                    var img = UIImage(named: savePath)
                    println(img)
                }

            }
        }
        
    }
    
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
    
    func getPhotos() {
        photosFromCoreData?.removeAll(keepCapacity: true)
        newCollectionBtn.enabled = false
        
        var spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(spinner)
        spinner.startAnimating()
        FlickrClient.sharedInstance().getPhotosForLocation(latitude, long: longitude, page: "\(currPage)") { (result, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    if let photos = result {
                        self.photosArr = photos.photoUrls.mutableCopy() as! NSMutableArray
                        if self.currPage <= self.photosArr.count {
                            self.currPage++
                        }
                        else {
                            self.newCollectionBtn.enabled = false
                        }
                    }
                    if self.photosArr.count > 0 {
                        self.noImagesLbl.hidden = true
                        self.collView.hidden = false
                        self.collView.reloadData()
                        spinner.stopAnimating()
                        self.newCollectionBtn.enabled = true
                    }
                    else {
                        self.noImagesLbl.hidden = false
                        self.collView.hidden = true
                        self.newCollectionBtn.enabled = false
                    }
                })
            }
            else {
                println("error")
            }
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var items = 1
    
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
       
        
        
        return items
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell : PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("image", forIndexPath: indexPath) as! PhotoCell
        
        if photosFromCoreData?.count > 0 {
            
        
        if let photosCoreData = photosFromCoreData as? Set<Photo> {
            let photos = Array(photosCoreData)
            let photoId = photos[indexPath.row].id!
            
            var documentsDir : String?
            
            var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            
            if paths.count > 0 {
                documentsDir = paths[0] as? String
                //let savePath = documentsDir! + "/\(idNum).jpg"
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
            println("applied Color")
        }
        
    }
    
    @IBAction func newCollection(sender: UIButton) {
        getPhotos()
    }
    
    
    @IBAction func removePictures(sender: UIButton) {
        //photosArr.removeObject(photosArr.objectAtIndex(0))
        
        
        //photosArr.removeObjectsAtIndexes(<#indexes: NSIndexSet#>)
        collView.performBatchUpdates({ () -> Void in
            
            
            for index in self.indexPaths {
                println(self.photosArr.count)
                println(index.row)
                
                if index.row >= self.photosArr.count {
                    self.photosArr.removeLastObject()
                }else {
                    self.photosArr.removeObjectAtIndex(index.row)
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
    /*func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    } */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
