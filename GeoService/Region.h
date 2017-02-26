//
//  Region.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/25/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>

@interface Region : MTLModel

@property (nonatomic, copy) NSString *regionId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger area;
@property (nonatomic) NSArray *border;
@property (nonatomic) NSArray *neighbors; // a list of ids., this avoids recursion issues.

@end
