//
//  Municipality.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <MapKit/MapKit.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>
#import "Region.h"

@interface Municipality : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *municipalityId; // or uid
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger area;
@property (nonatomic) NSArray *border;
@property (nonatomic) NSArray <NSString *> *neighbors;
@property (nonatomic) Region *region;

@end
