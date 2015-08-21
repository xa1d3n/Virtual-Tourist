//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/9/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var editButton : UIBarButtonItem!
    var doneButton : UIBarButtonItem!
    var uilpgr : UILongPressGestureRecognizer!
    
    var lat : String!
    var long : String!

    @IBOutlet weak var deletePinsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

        

     //   hideTapLabel()
    }
    
    func addPin(gestureRecognizer : UIGestureRecognizer) {
        // get touch location
        
        if deletePinsLbl.hidden == true {
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            
            // get coordinates
            let newCoordinate : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            

            var annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func removePin(gesture : UITapGestureRecognizer) {
        if deletePinsLbl.hidden == false {
            var viewTst = mapView.hitTest(gesture.locationInView(mapView), withEvent: nil)
            
            
            if (viewTst?.isKindOfClass(MKAnnotationView) == true) {
                var ann = viewTst as! MKAnnotationView
                var annotations = [AnyObject]()
                annotations.append(ann.annotation)
                mapView.removeAnnotations(annotations)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        mapView.removeAnnotation(view.annotation)
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
    
    
    
   /* override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier = "MainToTimer") {
            let secondViewController = segue.destinationViewController as YourSecondViewController
            let duration = sender as Double
            secondViewController.duration = duration
        }
    } */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhotoAlbum") {
            let secondViewController : PhotoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            
            secondViewController.latitude = lat
            secondViewController.longitude = long
            
            
        }
    }

    
    

}

