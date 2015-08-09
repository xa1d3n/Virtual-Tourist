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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add pin
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "addPin:")
        uilpgr.minimumPressDuration = 1.0
        // add gesture reconginzer to map view
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    func addPin(gestureRecognizer : UIGestureRecognizer) {
        // get touch location
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        
        // get coordinates
        let newCoordinate : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        // make annotation
        var annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        mapView.addAnnotation(annotation)
    }
    
    // handle pin click
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        self.performSegueWithIdentifier("showPhotoAlbum", sender: self)
        
    }

}

