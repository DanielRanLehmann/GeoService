//
//  Antenna.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 3/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Antenna.h"

@implementation Antenna

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"road" : @"vejnavn",
             @"houseNumber" : @"husnr",
             @"postcode" : @"postnummer",
             @"municipality" : @"kommune",
             @"commissioningDate" : @"idriftsættelsesdato", /* should be a date object eventually */
             //@"etrs89Coordinate" : @"etrs89koordinat",
             @"locationCoordinate" : @"wgs84koordinat",
             @"serviceType" : @"tjenesteart",
             @"technology" : @"teknologi"
             };
}

// setters goes here for all readonly properties.
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"road"]) {
    
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSString *href = [value[@"href"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *url = [NSURL URLWithString:href];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    
                    NSError *modelError = nil;
                    id model = nil;
                    
                    if ([key isEqualToString:@"road"]) {
                        model = [MTLJSONAdapter modelOfClass:Road.class fromJSONDictionary:json error:&modelError];
                    }
                    
                    else if ([key isEqualToString:@"postcode"]) {
                        model = [MTLJSONAdapter modelOfClass:Postcode.class fromJSONDictionary:json error:&modelError];
                    }
                    
                    else if ([key isEqualToString:@"municipality"]) {
                        model = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:json error:&modelError];
    
                    }
                    
                    else if ([key isEqualToString:@"municipality"]) {
                        model = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:json error:&modelError];
                    }
                    
                    else if ([key isEqualToString:@"serviceType"]) {
                        model = [MTLJSONAdapter modelOfClass:ServiceType.class fromJSONDictionary:json error:&modelError];
                    }
                    
                    else if ([key isEqualToString:@"technology"]) {
                        model = [MTLJSONAdapter modelOfClass:Technology.class fromJSONDictionary:json error:&modelError];
                    }
                    
                    if (!modelError) {
                        return model;
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
    
    else if ([key isEqualToString:@"locationCoordinate"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake([value[@"bredde"] doubleValue], [value[@"længde"] doubleValue])];
            }
            
            else {
                return nil;
            }
        }];
        
    }
    
    /*
     else if ([key isEqualToString:@"etrs89Coordinate"]) {
     return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
     if (success) {
     return [NSValue valueWithETRS89Coordinate:ETRS89CoordinateMake([value[@"nord"] doubleValue], [value[@"øst"] doubleValue])];
     }
     
     else {
     return nil;
     }
     }];
     
     }
     */
    
    return nil;
}

@end

@implementation ServiceType

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"serviceTypeId" : @"id",
             @"name" : @"navn"
             };
}

@end

@implementation Technology

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"technologyId" : @"id",
             @"name" : @"navn"
             };
}

@end
