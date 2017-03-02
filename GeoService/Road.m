//
//  Road.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 3/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Road.h"

@implementation Road

/*
 {
 "href": "http://geo.oiorest.dk/kommuner/0479/vejnavne/0010.json",
 "kode": "0010",
 "navn": "A P Møllers Vej",
 "postnummer": {
 "nr": "5700",
 "href": "http://geo.oiorest.dk/postnumre/5700.json"
 },
 "kommune": {
 "kode": "0479",
 "href": "http://geo.oiorest.dk/kommuner/0479.json"
 },
 "etrs89koordinat": {
 "øst": "601862",
 "nord": "6101691.52"
 },
 "wgs84koordinat": {
 "bredde": "55.0515657066061",
 "længde": "10.5944927880568"
 }
 }
 */


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"roadId" : @"kode",
             @"name" : @"navn",
             @"postcode" : @"postnummer",
             @"muncipality" : @"kommune",
             //@"etrs89Coordinate" : @"etrs89koordinat",
             @"locationCoordinate" : @"wgs84koordinat"
             };
}

// setters goes here for all readonly properties.
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"postcode"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSString *href = [value[@"href"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *url = [NSURL URLWithString:href];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                NSError *jsonError = nil;
                NSDictionary *postcodeJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    
                    NSError *modelError = nil;
                    Postcode *postcode = [MTLJSONAdapter modelOfClass:Postcode.class fromJSONDictionary:postcodeJSON error:&modelError];
                    if (!modelError) {
                        return postcode;
                        
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
    
    else if ([key isEqualToString:@"municipality"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSString *href = [value[@"href"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *url = [NSURL URLWithString:href];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                NSError *jsonError = nil;
                NSDictionary *municipalityJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    
                    NSError *modelError = nil;
                    Municipality *municipality = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:municipalityJSON error:&modelError];
                    if (!modelError) {
                        return municipality;
                        
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
