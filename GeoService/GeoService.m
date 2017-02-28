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

+ (void)transformCoordinates:(NSArray *)coordinates toFormat:(GSCoordinateFormat)format completionHandler:(void (^)(NSError *error, NSArray *transformedCoordinates))handler {
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"http";
    components.host = @"geo.oiorest.dk";
    
    NSString *coordStr = [coordinates componentsJoinedByString:@","];
    
    NSString *toFormat;
    NSString *fromFormat;
    
    switch (format) {
        case GSCoordinateFormatETRS89:
        {
            toFormat = @"etrs89";
            fromFormat = @"wgs84";
        }
            break;
            
        case GSCoordinateFormatWGS84:
        {
            toFormat = @"wgs84";
            fromFormat = @"etrs89";
        }
            
        default:
            break;
    }

    components.path = [NSString stringWithFormat:@"/%@.%@?%@=%@", toFormat, @"json", fromFormat, coordStr];
    
    NSURL *url = [NSURL URLWithString:[components.URL.absoluteString stringByRemovingPercentEncoding]];
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    //Not sure about options param: Look in docs.
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error && ([[json valueForKey:@"type"] isEqualToString:@"MultiPoint"] && [[json valueForKey:@"coordinates"] count] == (coordinates.count / 2))) {
        
        NSArray *transformedCoords = [json valueForKey:@"coordinates"]; // array has depth >= 1
        return handler(nil, transformedCoords);
    }
    
    else {
        return handler(error, nil);
    }
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
            [self getMunicipalityWithId:response[@"nr"] completionHandler:^(NSError *error, Municipality *municipality) {
                handler(error, municipality);
            }];
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
