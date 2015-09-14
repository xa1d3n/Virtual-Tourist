//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/9/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var editButton : UIBarButtonItem!
    var doneButton : UIBarButtonItem!
    var selectedPin : Pin?
    var uilpgr : UILongPressGestureRecognizer!
    let appDel : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var lat : String!
    var long : String!

    @IBOutlet weak var deletePinsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addPinsToMapFromCoreData()
        // add edit and done buttons to nav bar
        editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "edit")
        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done")
        
        
        self.navigationItem.rightBarButtonItem = editButton

        
        // add pin
        uilpgr = UILongPressGestureRecognizer(target: self, action: "addPin:")
        uilpgr.minimumPressDuration = 1.0
        // add gesture reconginzer to map view
        mapView.addGestureRecognizer(uilpgr)
        
        var tap = UITapGestureRecognizer(target: self, action: "removePin:")
        tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tap)
        
        
    }
    
    // Retrive pins from core data and add to map
    func addPinsToMapFromCoreData() {
        let results = getPinsFromCoreData()
        
        if results.count > 0 {
            for result : AnyObject in results {
                
                if let lat = result.valueForKey("latitude") as? String {
                    HelperFunctions.setPin(self.mapView, latitude: lat, longitude: result.valueForKey("longitude") as! String, shouldZoomIn: false)
                }
                
                
            }
        }else {
            println("no data")
        }
        
    }
    
    // retrevie pins from core data
    func getPinsFromCoreData() -> [AnyObject]{
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        var results : [AnyObject]?
        
        results = appDel.managedObjectContext?.executeFetchRequest(request, error: nil)
        
        return results!
    }
    

    // slide map up when edit button is clicked
    func resizeMap(makeSmaller : Bool) {
        let lblHeight : CGFloat = deletePinsLbl.frame.height
        let mapHeight : CGFloat = view.frame.height
        
        var newMapHeight : CGFloat
        if makeSmaller {
            newMapHeight = mapHeight - lblHeight
        }
        else {
            newMapHeight = mapHeight + lblHeight

        }
        
        UIView.animateWithDuration(1, animations: { () -> Void in
        self.mapView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.bounds.width, height: newMapHeight)
            
            self.deletePinsLbl.hidden = !makeSmaller
            self.mapView.autoresizingMask = self.view.autoresizingMask;
           
            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        deletePinsLbl.hidden = true
    }
    
    // handle edit button click
    func edit() {
        resizeMap(true)
        self.navigationItem.rightBarButtonItem = doneButton
        

    }
    
    // handle done editing button click
    func done() {
        resizeMap(false)
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    // add pin to map and display
    func addPin(gestureRecognizer : UIGestureRecognizer) {
        // get touch location
        
        if deletePinsLbl.hidden == true {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                let touchPoint = gestureRecognizer.locationInView(self.mapView)
                
                // get coordinates
                let newCoordinate : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)

                var annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                mapView.addAnnotation(annotation)
                
                
                let latt = "\(annotation.coordinate.latitude)" as String
                let longg = "\(annotation.coordinate.longitude)" as String

                PhotoLocations.getLocations(latt, longitude: longg, currPage: 1, pin: nil)
            }

        }
    }
    
    // handle removal of pin from map
    func removePin(gesture : UITapGestureRecognizer) {
        if deletePinsLbl.hidden == false {
            var viewTst = mapView.hitTest(gesture.locationInView(mapView), withEvent: nil)
            
            
            if (viewTst?.isKindOfClass(MKAnnotationView) == true) {
                var ann = viewTst as! MKAnnotationView
                var annotations = [AnyObject]()
                if let annotation = ann.annotation {
                    mapView.deselectAnnotation(annotation, animated: false)
                    annotations.append(annotation)
                    mapView.removeAnnotations(annotations)
                    
                    removePinsFromCoreData("\(annotation.coordinate.latitude)", longitude: "\(annotation.coordinate.longitude)")
                    
                    
                }
                
            }
        }
    }
    
    // remove pins from core data
    func removePinsFromCoreData(latitude : String, longitude : String) {
        let results = getPinsFromCoreData()
        
        if results.count > 0 {
            for result : AnyObject in results {
                if let latt : String =  result.valueForKey("latitude") as? String {
                    let longg : String =  result.valueForKey("longitude") as! String
                    
                    if latt == latitude && longitude == longg {
                        appDel.managedObjectContext?.deleteObject(result as! NSManagedObject)
                        
                        println("deleted object")
                    }
                    appDel.managedObjectContext?.save(nil)
                    
                }

            }
        }
        
    }
    
    
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if deletePinsLbl.hidden == false {
            mapView.deselectAnnotation(view.annotation, animated: false)
            mapView.removeAnnotation(view.annotation)
            
        }
    }
    
    
    
    
    // handle pin click
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        lat = "\(view.annotation.coordinate.latitude)"
        long = "\(view.annotation.coordinate.longitude)"
        
        if deletePinsLbl.hidden == true {
            self.performSegueWithIdentifier("showPhotoAlbum", sender: self)
        }
        else {
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.pinColor = .Red
            pinAnnotationView.animatesDrop = true
            pinAnnotationView.draggable = true
            

            
            return pinAnnotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == MKAnnotationViewDragState.Ending {
            updatePinFromCoreData(selectedPin!.latitude!, startingLong: selectedPin!.longitude, endingLat: "\(view.annotation.coordinate.latitude)", endingLong: "\(view.annotation.coordinate.longitude)")

            
        }
    }
    
    // update pin latitude/longitude and photos
    func updatePinFromCoreData(startingLat: String, startingLong : String, endingLat : String, endingLong: String) {
        let photoSet = selectedPin!.photos as? Set<Photo>
        let photoArray = Array(photoSet!)
        PhotoLocations.removePhotosFromCoreData(selectedPin!, photos: photoArray)
        PhotoLocations.removePhotosFromLibrary(selectedPin!, photos: photoArray)
        
        selectedPin?.latitude = endingLat
        selectedPin?.longitude = endingLong
        
        PhotoLocations.getLocations(endingLat, longitude: endingLong, currPage: 1, pin: selectedPin!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhotoAlbum") {
            let secondViewController : PhotoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            
            let photos = PhotoLocations.getPhotosFromCoreData(self, latitude: lat, longitude: long) as? Set<Photo>
            let photosArray = Array(photos!)
            secondViewController.photosFromCoreData = photosArray
            secondViewController.latitude = lat
            secondViewController.longitude = long
            secondViewController.pin = selectedPin
            
        }
    }

    
    

}

