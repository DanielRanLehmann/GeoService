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
#import <GeoJSONSerialization/GeoJSONSerialization.h>

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

typedef void(^municipalityCompletion)(NSError *error, Municipality *municipality);


+ (NSArray <id> *)convertCoordinates:(NSArray <id> *)coordinates fromSystem:(NSString *)fromSystem toSystem:(NSString *)toSystem;
+ (CLLocationCoordinate2D)locationCoordinateFromETRS89Coordinate:(ETRS89Coordinate)etrs89Coord;
+ (ETRS89Coordinate)etrs89CoordinateFromLocationCoordinate:(CLLocationCoordinate2D)wgs84Coord;


// Municipality Methods.

/*!
 @brief Returns a list of municipalities that match the search critieria.
 */
+ (void)getMunicipalitiesWithName:(NSString *)name completionHandler:(void (^)(NSError *error, NSArray <Municipality *> *municipalities))handler;

/*!
 @brief Returns a municipality with a matching id.
 */
+ (void)getMunicipalityWithId:(NSString *)municipalityId completionHandler:(void (^)(NSError *error, Municipality *municipality))handler;

/*!
 @brief Returns the municipality that encompasses the coordinates.
 */
+ (void)getMunicipalityWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate completionHandler:(void (^)(NSError *error, Municipality *municipality))handler;

/*!
 @brief Returns border of municipality with matching id.
 */
+ (void)getBorderOfMunicipalityWithId:(NSString *)municipalityId completionHandler:(void (^)(NSError *error, NSArray <MKPolygon *> *border))handler;

/*!
 @brief Returns a list of neighboring municipalities ids in regards to the id given.
 */
+ (void)getNeighborsOfMunicipalityWithId:(NSString *)municipalityId completionHandler:(void (^)(NSError *error, NSArray <NSString *> *neighbors))handler;

@end
