//
//  LocationPhotos.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/12/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

import Foundation


struct LocationPhotos {
    var page : NSNumber
    var pages : NSNumber!
    var perpage : NSNumber
    var photoUrls : NSArray
    
    
    init (dictionary: NSDictionary) {
        page = dictionary["page"] as! NSNumber
        pages = dictionary["pages"] as! NSNumber
        perpage = dictionary["perpage"] as! NSNumber
        photoUrls = dictionary["photo"] as! NSArray
    }
}
