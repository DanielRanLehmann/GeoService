//
//  PoliceDistrict.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/28/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "PoliceDistrict.h"

@implementation PoliceDistrict

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"policeDistrictId" : @"nr",
             @"name" : @"navn",
             @"area" : @"areal",
             @"border" : @"grænse",
             @"neighbors" : @"naboer"
             };
}

// setters goes here for all readonly properties.
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"area"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return [NSNumber numberWithUnsignedInteger:[str integerValue]];
            }
            
            else {
                return nil;
            }
        }];
    }
    
    else if ([key isEqualToString:@"neighbors"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSURL *URL = [NSURL URLWithString:[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                
                NSData *data = [NSData dataWithContentsOfURL:URL];
                
                NSDictionary *neighborsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSMutableArray *neighborIds = [NSMutableArray array];
                for (NSDictionary *neighbor in neighborsJSON) {
                    [neighborIds addObject:neighbor[@"nr"]];
                }
                
                return neighborIds;
            }
            
            else {
                return nil;
            }
        }];
    }
    
    else if ([key isEqualToString:@"border"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSArray *border = [NSArray array];
                
                NSURL *URL = [NSURL URLWithString:[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                NSData *data = [NSData dataWithContentsOfURL:URL];
                
                NSMutableDictionary *templateGeoJSON = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                       @"type": @"FeatureCollection"
                                                                                                       }];
                
                NSMutableDictionary *feature = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                               @"type": @"Feature",
                                                                                               @"properties": @{},
                                                                                               }];
                
                NSDictionary *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [feature setObject:geoJSON forKey:@"geometry"];
                [templateGeoJSON setObject:@[feature] forKey:@"features"];
                
                NSArray *shapes = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:templateGeoJSON error:nil];
                
                if (shapes.count > 0) {
                    border = [NSArray arrayWithArray:shapes];
                }
                
                return border;
                
            }else {
                return nil;
            }
        }];
    }
    
    return nil;
}


@end
