//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Aldin Fajic on 8/11/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

extension FlickrClient {
    
    // MARK: - Constants
    struct Constants {
        static let API_KEY : String = "5c9036c20ab0f619a7d9928cd67e97cf";
        static let BASE_URL : String = "https://api.flickr.com/services/rest/"
        static let DATA_FORMAT : String = "json"
        static let NO_JSON_CALLBACK : String = "1"
        static let EXTRAS : String = "url_m"
        static let GET_PHOTOS : String = "flickr.galleries.getPhotos"
    }
    
}
