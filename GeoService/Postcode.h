//
//  Postcode.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/28/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>
#import <MapKit/MapKit.h>

@interface Postcode : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *postcodeId;
@property (nonatomic) NSUInteger from;
@property (nonatomic) NSUInteger to;
@property (nonatomic) NSString *name;
@property (nonatomic) NSUInteger area;
@property (nonatomic) NSArray <MKPolygon *> *border;
@property (nonatomic) NSArray <NSString *> *neighbors;

@end
