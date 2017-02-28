//
//  PoliceDistrict.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/28/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>
#import <MapKit/MapKit.h>

@interface PoliceDistrict : MTLModel <MTLJSONSerializing>

/*
 "href": "http://geo.oiorest.dk/politikredse/10.json",
 "nr": "10",
 "navn": "Københavns Vestegns Politi",
 "areal": "277820000",
 "grænse": "http://geo.oiorest.dk/politikredse/10/grænse.json",
 "naboer": "http://geo.oiorest.dk/politikredse/10/naboer.json"
 */

@property (nonatomic) NSString *policeDistrictId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSUInteger area;
@property (nonatomic) NSArray <MKPolygon *> *border;
@property (nonatomic) NSArray <NSString *> *neighbors;

@end
