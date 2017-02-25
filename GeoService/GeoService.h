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
#import <AFNetworking/AFNetworking.h>

struct ETRS89Coordinate {
    
    double latitude;
    double longitude;
};
typedef struct ETRS89Coordinate ETRS89Coordinate;

CG_INLINE ETRS89Coordinate
ETRS89CoordinateMake(double latitude, double longitude) {
    
    ETRS89Coordinate coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    
    return coordinate;
}

@interface GeoService : NSObject

+ (Municipality *)municipalityWithLocation:(CLLocationCoordinate2D)locationCoord;

@end
