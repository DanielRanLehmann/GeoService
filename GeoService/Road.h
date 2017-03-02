//
//  Road.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 3/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "Postcode.h" 
#import "Municipality.h" 
#import <MapKit/MapKit.h>
//#import "GeoService.h"

@interface Road : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *roadId;
@property (nonatomic, copy) NSString *name;

@property (nonatomic) Postcode *postcode;
@property (nonatomic) Municipality *muncipality;

@property (nonatomic) CLLocationCoordinate2D locationCoordinate;
//@property (nonatomic) ETRS89Coordinate etrs89Coordinate;

@end
