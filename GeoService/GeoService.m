//
//  GeoService.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "GeoService.h"

@implementation GeoService

+ (NSArray <id> *)convertCoordinates:(NSArray <id> *)coordinates fromSystem:(NSString *)fromSystem toSystem:(NSString *)toSystem {
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"http";
    components.host = @"geo.oiorest.dk";
    
    NSString *coordStr = [coordinates componentsJoinedByString:@","];
    components.path = [NSString stringWithFormat:@"/%@.%@?%@=%@", toSystem, @"json", fromSystem, coordStr];
    
    NSURL *url = [NSURL URLWithString:[components.URL.absoluteString stringByRemovingPercentEncoding]];
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    //Not sure about options param: Look in docs.
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error && ([[json valueForKey:@"type"] isEqualToString:@"MultiPoint"] && [[json valueForKey:@"coordinates"] count] == (coordinates.count / 2))) {
        
        // check for type in (geo)json
        NSArray *array = [json valueForKey:@"coordinates"]; // array has depth >= 1
        return array; //locationCoord = CLLocationCoordinate2DMake([array[0][0] doubleValue], [array[0][1] doubleValue]); //ETRS89CoordinateMake([array[0][0] doubleValue], [array[0][1] doubleValue]);
    }
    
    return @[];
}

+ (CLLocationCoordinate2D)locationCoordinateFromETRS89Coordinate:(ETRS89Coordinate)etrs89Coord {
    
    CLLocationCoordinate2D locationCoord = CLLocationCoordinate2DMake(0, 0);
    
    // check for type in (geo)json
    NSArray *array = [self convertCoordinates:@[@(etrs89Coord.latitude), @(etrs89Coord.longitude)] fromSystem:@"etrs89" toSystem:@"wgs84"]; // array has depth >= 1
    if ([array[0] count] == 2) {
        locationCoord = CLLocationCoordinate2DMake([array[0][0] doubleValue], [array[0][1] doubleValue]); //ETRS89CoordinateMake([array[0][0] doubleValue], [array[0][1] doubleValue]);
    }
    
    return locationCoord;
}

// doesn't quiet work yet.
+ (ETRS89Coordinate)etrs89CoordinateFromLocationCoordinate:(CLLocationCoordinate2D)wgs84Coord {
    
    // sync method. User can call it in an async block though.
    ETRS89Coordinate etrs89Coord = ETRS89CoordinateMake(0, 0);
    
    // check for type in (geo)json
    NSArray *array = [self convertCoordinates:@[@(etrs89Coord.latitude), @(etrs89Coord.longitude)] fromSystem:@"wgs84" toSystem:@"etrs89"]; // array has depth >= 1
    if ([array[0] count] == 2) {
        etrs89Coord = ETRS89CoordinateMake([array[0][0] doubleValue], [array[0][1] doubleValue]); //ETRS89CoordinateMake([array[0][0] doubleValue], [array[0][1] doubleValue]);
    }
    
    return etrs89Coord;
}

+ (Municipality *)municipalityWithLocation:(CLLocationCoordinate2D)locationCoord {
    
    NSURL *baseUrl = [NSURL URLWithString:@"http://geo.oiorest.dk/"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    [manager GET:[NSString stringWithFormat:@"kommuner/%f,%f.json", locationCoord.latitude, locationCoord.longitude] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        NSLog(@"jsonDict: %@", jsonDict);
        
        //[jsonDict removeObjectsForKeys:@[@"areal", @"navn", @"nr", @"grænse"]];
        
        NSError *error = nil;
        Municipality *municipality = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:jsonDict error:&error];
        
        NSLog(@"adapter error: %@", error);
        NSLog(@"muni model:\n%@", municipality);
        
        //return municipality;
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        //return error;
    }];
    
    return nil;
}

@end

@implementation NSValue (NSValueMapKitETRS89CoordinateExtension)

+ (NSValue *)valueWithETRS89Coordinate:(ETRS89Coordinate)coordinate {
    
    return [NSValue value:&coordinate withObjCType:@encode(ETRS89Coordinate)];
}

- (ETRS89Coordinate)ETRS89CoordinateValue {
    
    ETRS89Coordinate coordinate;
    [self getValue:&coordinate];
    
    return coordinate;
}

@end
