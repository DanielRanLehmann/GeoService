//
//  Region.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/25/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Region.h"

@implementation Region

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             //@"hrefUrl" : @"href",
             @"regionId" : @"nr",
             @"name" : @"navn",
             @"area" : @"areal",
             @"border" : @"grænse",
             @"neighbors" : @"naboer"
             };
}

// setters goes here for all readonly properties.
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"neighbors"]) {
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
    
    else if ([key isEqualToString:@"hrefUrl"] || [key isEqualToString:@"border"]) {
        
        if ([key isEqualToString:@"border"]) {
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
        
        else {
            //return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
            return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
                if (success) {
                    NSString *urlEncodedString  = [self urlencodeString:str];
                    return [NSURL URLWithString:urlEncodedString];
                }else{
                    return @"";
                }
                
            }];
        }
        
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
