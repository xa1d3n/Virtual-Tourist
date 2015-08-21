//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/9/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import UIKit
import MapKit

var photosArr : NSMutableArray!

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var longitude : String!
    var latitude : String!
    var currPage = 1
    
    var indexPaths = [NSIndexPath]()
   
    
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!

    @IBOutlet weak var removeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // getPhotos()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        setPin()
        getPhotos()
        
    }
    
    func setPin() {
        var lat : CLLocationDegrees = (latitude as NSString).doubleValue
        var lon : CLLocationDegrees = (longitude as NSString).doubleValue
        
        var latDelta : CLLocationDegrees = 0.01
        var lonDelta : CLLocationDegrees = 0.01
        
        var span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        var location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        
        var region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    func getPhotos() {
        newCollectionBtn.enabled = false
        FlickrClient.sharedInstance().getPhotosForLocation(latitude, long: longitude, page: "\(currPage)") { (result, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    if let photos = result {
                        photosArr = photos.photoUrls.mutableCopy() as! NSMutableArray
                        if self.currPage <= photosArr.count {
                            self.currPage++
                        }
                        else {
                            self.newCollectionBtn.enabled = false
                        }
                    }
                    self.collView.reloadData()
                    self.newCollectionBtn.enabled = true
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
        println(photosArr?.count)
        
        var items = 5
        
        if let photoCount = photosArr?.count {
            items = photoCount
        }
        
        return items
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell : PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("image", forIndexPath: indexPath) as! PhotoCell
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let urlString = photosArr?.objectAtIndex(indexPath.row)["url_m"]  as? String {
                let url = NSURL(string: urlString)
                let data = NSData(contentsOfURL: url!)
                
                
                let image = UIImage(data: data!)
                
                
                
                dispatch_async(dispatch_get_main_queue(), {
                 cell.imageView.image = image
                })
            }
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        removeBtn.hidden = false
        newCollectionBtn.hidden = true
        
        indexPaths.append(indexPath)
        var cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if cell?.layer.borderWidth == 2.0 {
            cell?.layer.borderWidth = 0.0
            
            var i = 0
            for index in indexPaths {
                if index == indexPath {
                    indexPaths.removeAtIndex(i)
                }
                i++
            }
        }else {
            cell?.layer.borderWidth = 2.0
            cell?.layer.borderColor = UIColor.redColor().CGColor
            
            
        }
    }
    
    @IBAction func newCollection(sender: UIButton) {
        getPhotos()
    }
    
    
    @IBAction func removePictures(sender: UIButton) {
        //photosArr.removeObject(photosArr.objectAtIndex(0))
        
        for index in indexPaths {
            photosArr.removeObjectAtIndex(index.row)
        }
        //photosArr.removeObjectsAtIndexes(<#indexes: NSIndexSet#>)
        collView.performBatchUpdates({ () -> Void in
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
