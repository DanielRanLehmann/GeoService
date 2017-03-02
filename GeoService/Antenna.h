//
//  Antenna.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 3/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "Road.h"
#import "Postcode.h"
#import "Municipality.h" 

#import <MapKit/MapKit.h>

@class ServiceType, Technology;
@interface Antenna : MTLModel <MTLJSONSerializing>

@property (nonatomic) Road *road;
@property (nonatomic, copy) NSString *houseNumber;
@property (nonatomic) Postcode *postcode;
@property (nonatomic) Municipality *municipality;
@property (nonatomic) NSString *commissioningDate;
// ETRS89Coordinate.. not yet. look in road for full implementation.
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic) ServiceType *serviceType;
@property (nonatomic) Technology *technology;

@end

@interface ServiceType : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *serviceTypeId;
@property (nonatomic, copy) NSString *name;

@end

@interface Technology : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *technologyId;
@property (nonatomic, copy) NSString *name;

@end
