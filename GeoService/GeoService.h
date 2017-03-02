//
//  GeoService.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>

// MODELS
#import "Municipality.h"
#import "Postcode.h"
#import "PoliceDistrict.h"
#import "Antenna.h"
#import "Road.h"

// USING THESE LIBS.
#import <MapKit/MapKit.h>
#import <AFNetworking/AFNetworking.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>

/*
struct SouthWest {
    double latitude;
    double longitude;
};
typedef struct SouthWest SouthWest;

struct NorthEast {
    double latitude;
    double longitude;
};
typedef struct NorthEast NorthEast;
*/

struct BBox {
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
};
typedef struct BBox BBox;

CG_INLINE BBox
BBoxMake(CLLocationCoordinate2D southWest, CLLocationCoordinate2D northEast) {
    
    BBox box;
    box.southWest = southWest;
    box.northEast = northEast;
    
    return box;
}

// maybe switch north and east position?
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

NS_ASSUME_NONNULL_BEGIN

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

/* POLICE DISTRICT */
+ (void)getPoliceDistrictWithName:(NSString *)name completionHandler:(void (^)(NSError *error, NSArray <PoliceDistrict *> *policeDistricts))handler;

+ (void)getPoliceDistrictWithId:(NSString *)policeDistrictId completionHandler:(void (^)(NSError *error, PoliceDistrict *policeDistrict))handler;

+ (void)getPoliceDistrictWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate completionHandler:(void (^)(NSError *error, PoliceDistrict *policeDistrict))handler;

+ (void)getBorderOfPoliceDistrictWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *errror, NSArray <MKPolygon *> *border))handler;

+ (void)getNeighborsOfPoliceDistrictWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *error, NSArray <NSString *> *neighbors))handler;

/* antennas */
+ (void)getAllTechnologiesWithCompletionHandler:(void (^)(NSError *error, NSArray <Technology *> *technologies))handler;

+ (void)getAllServiceTypesWithCompletionHandler:(void (^)(NSError *error, NSArray <ServiceType *> *serviceTypes))handler;

+ (void)getAntennasWithinRadius:(NSUInteger)radius ofLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate serviceTypeName:(nullable NSString *)serviceTypeName technologyName:(nullable NSString *)technologyName completionHandler:(void (^)(NSError *_Nullable error, NSArray <Antenna *> * _Nullable antennas))handler;

+ (void)getAntennasWithBBox:(BBox)bbox serviceTypeName:(nullable NSString *)serviceTypeName technologyName:(nullable NSString *)technologyName completionHandler:(void (^)(NSError *error, NSArray <Antenna *> *antennas))handler;

+ (void)getNearestAntennaWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate serviceTypeName:(nullable NSString *)serviceTypeName technologyName:(nullable NSString *)technologyName completionHandler:(void (^)(NSError *error, Antenna *antenna))handler;

+ (void)getAntennasWithPostcode:(NSUInteger)postcode muncipalityId:(nullable NSString *)muncipalityId serviceType:(nullable NSString *)serviceType technology:(nullable NSString *)technology maxCount:(NSUInteger)maxCount completionHandler:(void (^)(NSError *error, NSArray <Antenna *> *antennas))handler;

// ROADS

// simple search for road name
+ (void)getRoadsWithName:(nonnull NSString *)roadName maxCount:(NSUInteger)maxCount completionHandler:(void (^)(NSError *error, NSArray <Road *> *roads))handler;

// more attri search for road name.
+ (void)getRoadsWithName:(nonnull NSString *)roadName postcode:(NSUInteger)postcode fromPostcode:(NSUInteger)fromPostcode toPostcode:(NSUInteger)toPostcode muncipalityId:(nullable NSString *)muncipalityId roadId:(nullable NSString *)roadId maxCount:(NSUInteger)maxCount completionHandler:(void (^)(NSError *error, NSArray <Road *> *roads))handler;

+ (void)getRoadWithId:(nonnull NSString *)roadId muncipalityId:(nullable NSString *)muncipalityId completionHandler:(void (^)(NSError *error, Road *road))handler;

// LANDLOT (TWO WORDS)

+ (void)getLandLotWithName:(nonnull NSString *)landLotName landlotId:(nullable NSString *)landlotId municipalityId:(nullable NSString *)municipalityId regionId:(nullable NSString *)regionId maxCount:(NSUInteger)maxCount;

+ (void)getLandLotWithId:(nonnull NSString *)landLotId municipalityId:(nullable NSString *)municipalityId;


@end

@interface NSValue (NSValueMapKitETRS89CoordinateExtension)

+ (NSValue *)valueWithETRS89Coordinate:(ETRS89Coordinate)coordinate;
- (ETRS89Coordinate)ETRS89CoordinateValue;

@end

NS_ASSUME_NONNULL_END

