//
//  GeoService.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "GeoService.h"
#define BASE_URL @"http://geo.oiorest.dk"

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

+ (void)requestWithPath:(NSString *)requestPath completionHandler:(void (^)(NSError *error, id response))handler {
    
    if (![requestPath hasPrefix:@"/"]) {
        requestPath = [NSString stringWithFormat:@"/%@", requestPath];
    }
    NSURL *baseUrl = [NSURL URLWithString:BASE_URL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    [manager GET:requestPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        handler(nil, responseObject);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        handler(error, nil);
    }];
}

// MUNICIPALITY WORK.
+ (void)getMunicipalitiesWithName:(NSString *)name completionHandler:(void (^)(NSError *error, NSArray <Municipality *> *municipalities))handler {

    [self requestWithPath:[NSString stringWithFormat:@"/kommuner.json?q=%@", name] completionHandler:^(NSError *error, id response) {
        if (!error) {
            // do something here.
            
            NSMutableArray <Municipality *> *municipalities = [NSMutableArray array];
            for (NSDictionary *municipality in response) {
                NSError *modelError = nil;
                Municipality *_municipality = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:municipality error:&modelError];
                if (!modelError) {
                    [municipalities addObject:_municipality];
                }
            }
            
            handler(nil, municipalities);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getMunicipalityWithId:(NSString *)municipalityId completionHandler:(void (^)(NSError *error, Municipality *municipality))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"/kommuner/%@.json", municipalityId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSError *modelError = nil;
            Municipality *municipality = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:response error:&modelError];
            if (!error) {
                handler(nil, municipality);
            
            } else {
                handler(modelError, nil);
            }
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getMunicipalityWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate completionHandler:(void (^)(NSError *error, Municipality *municipality))handler {

    [self requestWithPath:[NSString stringWithFormat:@"kommuner/%f,%f.json", locationCoordinate.latitude, locationCoordinate.longitude] completionHandler:^(NSError *error, id response) {
        if (!error) {
            if (response[@"nr"]) {
                [self getMunicipalityWithId:response[@"nr"] completionHandler:^(NSError *error, Municipality *municipality) {
                    handler(error, municipality);
                }];
                
                /*
                NSError *modelError = nil;
                Municipality *municipality = [MTLJSONAdapter modelOfClass:Municipality.class fromJSONDictionary:response error:&modelError];
                if (!error) {
                    handler(nil, municipality);
                    
                } else {
                    handler(modelError, nil);
                }
                */
            }
            
        }
        
        else {
            handler(error, nil);
        }
    }];
}


+ (void)getBorderOfMunicipalityWithId:(NSString *)municipalityId completionHandler:(void (^)(NSError *, NSArray<MKPolygon *> *))handler {
    [self requestWithPath:[NSString stringWithFormat:@"/kommuner/%@/graense.json", municipalityId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            NSArray <MKPolygon *> *border = [NSArray array];
            
            NSMutableDictionary *templateGeoJSON = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                   @"type": @"FeatureCollection"
                                                                                                   }];
            
            NSMutableDictionary *feature = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                           @"type": @"Feature",
                                                                                           @"properties": @{},
                                                                                           }];
            
            NSDictionary *geoJSON = [NSDictionary dictionaryWithDictionary:response];
            [feature setObject:geoJSON forKey:@"geometry"];
            [templateGeoJSON setObject:@[feature] forKey:@"features"];
            
            NSArray *shapes = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:templateGeoJSON error:nil];
            
            if (shapes.count > 0) {
                border = [NSArray arrayWithArray:shapes];
            }
            
            handler(nil, border);

        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getNeighborsOfMunicipalityWithId:(NSString *)municipalityId completionHandler:(void (^)(NSError *error, NSArray <NSString *> *neighbors))handler {

    [self requestWithPath:[NSString stringWithFormat:@"kommuner/%@/naboer.json", municipalityId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSArray *neighbors = [NSArray arrayWithArray:response];
            
            NSMutableArray <NSString *> *neighborIds = [NSMutableArray array];
            
            for (NSDictionary *neighbor in neighbors) {
                [neighborIds addObject:neighbor[@"nr"]];
            }
            
            handler(nil, neighborIds);
        }
        
        else {
            handler(error, nil);
        }
    }];
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
