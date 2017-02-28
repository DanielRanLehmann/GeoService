//
//  Region.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/25/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>
#import <MapKit/MapKit.h>

@interface Region : MTLModel <MTLJSONSerializing> 

@property (nonatomic, copy) NSString *regionId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger area;
@property (nonatomic) NSArray <MKPolygon *> *border;
@property (nonatomic) NSArray <NSString *> *neighbors; // a list of ids., this avoids recursion issues.

@end
