//
//  GeoserviceV2.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 3/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    GSMethodTypeAddress,
    GSMethodTypePAddress,
    GSMethodTypeNAddress,
    GSMethodTypeRoad,
    GSMethodTypePostalCode,
    GSMethodTypeMunicipality,
    GSMehtodTypeParish,
    GSMethodTypePoliceDistrict,
    GSMethodTypeConstituency,
    GSMethodTypeJurisdiction,
    GSMethodTypeOwnerAssociations,
    GSMethodTypeLandRegisterNumber,
    GSMethodTypeAssessingProperty,
    GSMethodTypeRealEstate,
    GSMethodTypePlace,
    GSMethodTypePlaceCategory,
    GSMethodTypeHeight
    // Include transformCoordinates?
} GSMethodTypes;

@interface GeoserviceV2 : NSObject

- (instancetype)initWithLogin:(NSString *)login password:(NSString *)password;

- (void)GET:(GSMethodTypes)methodType parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error, id response))handler;

// Raw ?
- (void)GETMethodWithName:(NSString *)methodName parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error, id response))handler;

- (void)transformCoordinates:(NSArray <NSNumber *> *)coordinates fromESPG:(NSUInteger)fromESPG toESPG:(NSUInteger)toESPG completionHandler:(void (^)(NSError *error, id response))handler;

@end
