//
//  Municipality.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Municipality.h"

@implementation Municipality

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"href": @"hrefUrl",
             @"nr": @"identifier",
             @"navn": @"name",
             @"areal": @"area",
             @"grænse": @"borderUrl"
             };
}

@end
