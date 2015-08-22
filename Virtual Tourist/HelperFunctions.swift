//
//  HelperFunctions.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/22/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import Foundation
import MapKit

struct HelperFunctions {
    
    static func setPin(mapView : MKMapView, latitude: String, longitude: String, shouldZoomIn: Bool) {
        var lat : CLLocationDegrees = (latitude as NSString).doubleValue
        var lon : CLLocationDegrees = (longitude as NSString).doubleValue
        var location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        
        if shouldZoomIn {
            var latDelta : CLLocationDegrees = 0.01
            var lonDelta : CLLocationDegrees = 0.01
            
            var span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            
            
            
            var region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
        }
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
}