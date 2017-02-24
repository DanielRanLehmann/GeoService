//
//  GeoService.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Municipality.h"
#import <MapKit/MapKit.h>
#import <AFNetworking.h>

@interface GeoService : NSObject

+ (Municipality *)municipalityWithLocation:(CLLocationCoordinate2D)locationCoord;

@end
