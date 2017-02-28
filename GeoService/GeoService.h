//
//  GeoService.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Municipality.h"
#import "Postcode.h"

#import <MapKit/MapKit.h>
#import <AFNetworking/AFNetworking.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>

struct ETRS89Coordinate {
    double north;
    double east;
};
typedef struct ETRS89Coordinate ETRS89Coordinate;

CG_INLINE ETRS89Coordinate
ETRS89CoordinateMake(double north, double east) {
    
    ETRS89Coordinate coordinate;
    coordinate.north = north;
    coordinate.east = east;
    
    return coordinate;
}

typedef enum : NSUInteger {
    GSCoordinateFormatETRS89,
    GSCoordinateFormatWGS84
} GSCoordinateFormat;

@interface GeoService : NSObject

// Coordinate Transformation

+ (void)transformCoordinates:(NSArray *)coordinates toFormat:(GSCoordinateFormat)format completionHandler:(void (^)(NSError *error, NSArray *transformedCoordinates))handler;

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

/* POSTAL CODES METHODS */

+ (void)getPostcodesWithName:(NSString *)name completionHandler:(void (^)(NSError *error, NSArray <Postcode *> *postcodes))handler;

+ (void)getPostcodesForMuncipalityWithId:(NSString *)muncipalityId completionHandler:(void (^)(NSError *error, NSArray <Postcode *> *postcodes))handler;

+ (void)getPostcodeWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *error, Postcode *postcode))handler;

+ (void)getPostcodeWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate completionHandler:(void (^)(NSError *error, Postcode *postcode))handler;

+ (void)getBorderOfPostcodeWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *errror, NSArray <MKPolygon *> *border))handler;

+ (void)getNeighborsOfPostcodeWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *error, NSArray <NSString *> *neighbors))handler;

@end
