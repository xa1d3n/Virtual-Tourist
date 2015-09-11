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
        uilpgr.minimumPressDuration = 0.5
        // add gesture reconginzer to map view
        mapView.addGestureRecognizer(uilpgr)
        
        var tap = UITapGestureRecognizer(target: self, action: "removePin:")
        tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tap)
        
        
    }
    
    func addPinsToMapFromCoreData() {
        let results = getPinsFromCoreData()
        
        
        if results.count > 0 {
            for result : AnyObject in results {
                //println(result.valueForKey("photos") as! _NSFaultingMutableSet!)
                //println(result.photos)
               // let photos = result.photos as! [Photo]
             //   println(result.latitude)
               // result.getPh
               // println(photos)
                
                
                if let lat = result.valueForKey("latitude") as? String {
                    HelperFunctions.setPin(self.mapView, latitude: lat, longitude: result.valueForKey("longitude") as! String, shouldZoomIn: false)
                }
                
                
            }
        }else {
            println("no data")
        }
        
    }
    
    func getPinsFromCoreData() -> [AnyObject]{
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        var results : [AnyObject]?
        
        results = appDel.managedObjectContext?.executeFetchRequest(request, error: nil)
        
        return results!
    }
    
    func getPhotosFromCoreData(latitude: String, longitude: String) -> Set<NSObject> {
        let request = NSFetchRequest(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        
        let latPred = NSPredicate(format: "latitude = %@", latitude)
        let longPred = NSPredicate(format: "longitude = %@", longitude)
        
        var compound = NSCompoundPredicate.andPredicateWithSubpredicates([latPred, longPred])
        request.predicate = compound
        
        var results : [Pin]
        
        results = appDel.managedObjectContext?.executeFetchRequest(request, error: nil) as! [Pin]
        
        return results[0].photos
        
        /*
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LogItem] {
            logItems = fetchResults
        }*/
       // return results.
    }
    
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
    
    func edit() {
        resizeMap(true)
        self.navigationItem.rightBarButtonItem = doneButton
        

    }
    
    func done() {
        resizeMap(false)
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func addPin(gestureRecognizer : UIGestureRecognizer) {
        // get touch location
        
        if deletePinsLbl.hidden == true {
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            
            // get coordinates
            let newCoordinate : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            println(newCoordinate)

            var annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            mapView.addAnnotation(annotation)
            
            
            let latt = "\(annotation.coordinate.latitude)" as String
            let longg = "\(annotation.coordinate.longitude)" as String

            PhotoLocations.getLocations(latt, longitude: longg, currPage: 1)
          //  println("\(annotation.coordinate.longitude)")
            //println("\(annotation.coordinate.latitude)")
            
          /*  let context = appDel.managedObjectContext
            
            var newPin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: context!) as! NSManagedObject
            
            // specify attributes
            
            let latt = "\(annotation.coordinate.latitude)" as String
            let longg = "\(annotation.coordinate.longitude)" as String
            
            PhotoLocations.getLocations(latt, longitude: longg, currPage: 1)
            
          //  println(appDel.photoUrls)
            
            newPin.setValue(latt, forKey: "latitude")
            newPin.setValue(longg, forKey: "longitude")
            
            context?.save(nil) */

        }
    }
    
    
    func removePin(gesture : UITapGestureRecognizer) {
        if deletePinsLbl.hidden == false {
            println("deleting")
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
        println("Deselected")
        if deletePinsLbl.hidden == false {
          //  removePinsFromCoreData("\(view.annotation.coordinate.latitude)", longitude: "\(view.annotation.coordinate.longitude)")
            mapView.deselectAnnotation(view.annotation, animated: false)
            mapView.removeAnnotation(view.annotation)
            
        }
    }
    
    
    
    
    // handle pin click
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("selected pin")
        
        lat = "\(view.annotation.coordinate.latitude)"
        long = "\(view.annotation.coordinate.longitude)"
        
        
        
        //println(self.getPhotosFromCoreData(lat, longitude: long).count)
        
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
        
        var startAnn : MKAnnotation!
        
     //   var startingLat : String = ""
       // var startingLong = "\(view.annotation.coordinate.longitude)"
        println("start drag\(view.annotation.coordinate.latitude)")
        if newState == MKAnnotationViewDragState.Dragging {
            println("draggin it")

        }
        
        if newState == MKAnnotationViewDragState.Ending {
            println(startAnn.coordinate.latitude)
          //  println("end drag\(view.annotation.coordinate.latitude)")
            //update pin location
            /*if let customAnnot = view.annotation as? myAnnotation {
                cData.updatePinLocation(customAnnot.pinID, newValue: customAnnot.coordinate)
            } */
            //println(startingLat)
           // println(startingLong)
            //updatePinFromCoreData(startingLat, startingLong: startingLong, endingLat: "\(view.annotation.coordinate.latitude)", endingLong: "\(view.annotation.coordinate.longitude)")

            
        }
        

        
        if newState == MKAnnotationViewDragState.Starting {
            startAnn = view.annotation
            println(startAnn.coordinate.latitude)
           // println("start drag")
            //println("\(view.annotation.coordinate.latitude)")
            //startingLat = "\(view.annotation.coordinate.latitude)"
            //startingLong = "\(view.annotation.coordinate.longitude)"
        }
    }
    
    func updatePinFromCoreData(startingLat: String, startingLong : String, endingLat : String, endingLong: String) {
        let results = getPinsFromCoreData()
        
        if results.count > 0 {
            for result : AnyObject in results {
                
                let latt : String =  result.valueForKey("latitude") as! String
                let longg : String =  result.valueForKey("longitude") as! String
                
                if latt == startingLat && longg == startingLong {
                    
                    result.setValue(endingLat, forKey: latt)
                    result.setValue(endingLong, forKey: longg)
                    println("updated location")
                }
                appDel.managedObjectContext?.save(nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhotoAlbum") {
            let secondViewController : PhotoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            
           // let phtos = self.getPhotosFromCoreData(lat, longitude: long)[0]
            //println(self.getPhotosFromCoreData(lat, longitude: long).count)
            
            secondViewController.photosFromCoreData = self.getPhotosFromCoreData(lat, longitude: long) as? Set<NSObject>
            secondViewController.latitude = lat
            secondViewController.longitude = long
            
        }
    }

    
    

}

