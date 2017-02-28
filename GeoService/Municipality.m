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
             @"municipalityId" : @"nr",
             @"name" : @"navn",
             @"area" : @"areal",
             @"border" : @"grænse",
             @"neighbors" : @"naboer",
             @"region" : @"region"
             };
}

// setters goes here for all readonly properties.
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"region"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSString *href = [value[@"href"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *url = [NSURL URLWithString:href];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                NSError *jsonError = nil;
                NSDictionary *regionJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    
                    NSError *modelError = nil;
                    Region *region = [MTLJSONAdapter modelOfClass:Region.class fromJSONDictionary:regionJSON error:&modelError];
                    if (!modelError) {
                        return region;
                        
                    } else {
                        return nil;
                    }
                }
                
                else {
                    return nil;
                }
            }
            
            else {
                return nil;
            }
        }];
    }
    
    else if ([key isEqualToString:@"neighbors"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSMutableArray <NSString *> *neighborIds = [NSMutableArray array];
                
                NSURL *URL = [NSURL URLWithString:[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                NSData *data = [NSData dataWithContentsOfURL:URL];
                
                NSError *jsonError = nil;
                NSDictionary *neighbors = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    
                    for (NSDictionary *neighbor in (NSArray *)neighbors) {
                        [neighborIds addObject:neighbor[@"nr"]];
                    }
                }
                
                else {
                    return nil;
                }
                
                return neighborIds;
            }
            
            else {
                return nil;
            }
        }];
    }
    
    else if ([key isEqualToString:@"area"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return [NSNumber numberWithInteger:[str integerValue]];
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
                
                NSURL *URL = [NSURL URLWithString:[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]; //[[NSBundle mainBundle] URLForResource:@"map" withExtension:@"geojson"];
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

+ (NSString *)urlencodeString:(NSString*)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
