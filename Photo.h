//
//  Photo.h
//  Virtual Tourist
//
//  Created by Aldin Fajic on 9/1/15.
//  Copyright (c) 2015 Aldin Fajic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pin;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Pin *pin;

@end
