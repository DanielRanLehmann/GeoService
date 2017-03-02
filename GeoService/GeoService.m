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

/* POSTAL CODES METHODS */
+ (void)getPostcodesWithName:(NSString *)name completionHandler:(void (^)(NSError *error, NSArray <Postcode *> *postcodes))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"postnumre.json?q=%@", [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSMutableArray <Postcode *> *postcodes = [NSMutableArray array];
            for (NSDictionary *postcode in response) {
                NSError *modelError = nil;
                Postcode *_postcode = [MTLJSONAdapter modelOfClass:Postcode.class fromJSONDictionary:postcode error:&modelError];
                if (!modelError) {
                    [postcodes addObject:_postcode];
                }
            }
            
            handler(nil, postcodes);
        }
        
        else {
            handler(error, nil);
        }
        
    }];
}

+ (void)getPostcodesForMuncipalityWithId:(NSString *)muncipalityId completionHandler:(void (^)(NSError *error, NSArray <Postcode *> *postcodes))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"kommuner/%@/postnumre.json", muncipalityId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSMutableArray <Postcode *> *postcodes = [NSMutableArray array];
            for (NSDictionary *rawPostcode in response) {
                [self getPostcodeWithId:rawPostcode[@"nr"] completionHandler:^(NSError *error, Postcode *postcode) {
                    if (!error) {
                        [postcodes addObject:postcode];
                    }
                }];
            }
            
            handler(nil, postcodes);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getPostcodeWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *error, Postcode *postcode))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"postnumre/%@.json", postcodeId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSError *modelError = nil;
            Postcode *postcode = [MTLJSONAdapter modelOfClass:Postcode.class fromJSONDictionary:response error:&modelError];
            if (!modelError) {
                handler(nil, postcode);
            }
            
            else {
                handler(modelError, nil);
            }
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getPostcodeWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate completionHandler:(void (^)(NSError *error, Postcode *postcode))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"postnumre/%f,%f.json", locationCoordinate.latitude, locationCoordinate.longitude] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSError *modelError = nil;
            Postcode *postcode = [MTLJSONAdapter modelOfClass:Postcode.class fromJSONDictionary:response error:&modelError];
            if (!modelError) {
                handler(nil, postcode);
            }
            
            else {
                handler(modelError, nil);
            }
            
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getBorderOfPostcodeWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *errror, NSArray <MKPolygon *> *border))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"postnumre/%@/graense.json", postcodeId] completionHandler:^(NSError *error, id response) {
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

+ (void)getNeighborsOfPostcodeWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *error, NSArray <NSString *> *neighbors))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"postnumre/%@/naboer.json", postcodeId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            NSArray *neighbors = [NSArray arrayWithArray:response];
            
            NSMutableArray <NSString *> *neighborIds = [NSMutableArray array];
            
            for (NSDictionary *neighbor in neighbors) {
                [neighborIds addObject:neighbor[@"nr"]];
            }
            
            handler(nil, neighborIds);
        }
        
        else {
            return handler(error, nil);
        }
    }];
}


+ (void)getPoliceDistrictWithName:(NSString *)name completionHandler:(void (^)(NSError *error, NSArray <PoliceDistrict *> *policeDistricts))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"politikredse.json?q=%@", [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSMutableArray <PoliceDistrict *> *policeDistricts = [NSMutableArray array];
            for (NSDictionary *policeDistrict in response) {
                NSError *modelError = nil;
                PoliceDistrict *_policeDistrict = [MTLJSONAdapter modelOfClass:PoliceDistrict.class fromJSONDictionary:policeDistrict error:&modelError];
                if (!modelError) {
                    [policeDistricts addObject:_policeDistrict];
                }
            }
            
            handler(nil, policeDistricts);
        }
        
        else {
            handler(error, nil);
        }
        
    }];
}

+ (void)getPoliceDistrictWithId:(NSString *)policeDistrictId completionHandler:(void (^)(NSError *error, PoliceDistrict *policeDistrict))handler {

    [self requestWithPath:[NSString stringWithFormat:@"politikredse/%@.json", policeDistrictId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSError *modelError = nil;
            PoliceDistrict *policeDistrict = [MTLJSONAdapter modelOfClass:PoliceDistrict.class fromJSONDictionary:response error:&modelError];
            if (!modelError) {
                handler(nil, policeDistrict);
            }
            
            else {
                handler(modelError, nil);
            }
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getPoliceDistrictWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate completionHandler:(void (^)(NSError *error, PoliceDistrict *policeDistrict))handler {

    [self requestWithPath:[NSString stringWithFormat:@"politikredse/%f,%f.json", locationCoordinate.latitude, locationCoordinate.longitude] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSError *modelError = nil;
            PoliceDistrict *policeDistrict = [MTLJSONAdapter modelOfClass:PoliceDistrict.class fromJSONDictionary:response error:&modelError];
            if (!modelError) {
                handler(nil, policeDistrict);
            }
            
            else {
                handler(modelError, nil);
            }
            
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getBorderOfPoliceDistrictWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *errror, NSArray <MKPolygon *> *border))handler {

    [self requestWithPath:[NSString stringWithFormat:@"politikredse/%@/graense.json", postcodeId] completionHandler:^(NSError *error, id response) {
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

+ (void)getNeighborsOfPoliceDistrictWithId:(NSString *)postcodeId completionHandler:(void (^)(NSError *error, NSArray <NSString *> *neighbors))handler {

    [self requestWithPath:[NSString stringWithFormat:@"politikredse/%@/naboer.json", postcodeId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            NSArray *neighbors = [NSArray arrayWithArray:response];
            
            NSMutableArray <NSString *> *neighborIds = [NSMutableArray array];
            
            for (NSDictionary *neighbor in neighbors) {
                [neighborIds addObject:neighbor[@"nr"]];
            }
            
            handler(nil, neighborIds);
        }
        
        else {
            return handler(error, nil);
        }
    }];
}

/* antennas */
+ (void)getAllTechnologiesWithCompletionHandler:(void (^)(NSError *error, NSArray <Technology *> *technologies))handler {

    [self requestWithPath:@"antenner/teknologier.json" completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSMutableArray <Technology *> *technologies = [NSMutableArray array];
            for (NSDictionary *technologyDict in response) {
                NSError *modelError = nil;
                Technology *technology = [MTLJSONAdapter modelOfClass:Technology.class fromJSONDictionary:technologyDict error:&modelError];
                if (!modelError) {
                    [technologies addObject:technology];
                }
            }
            
            handler(nil, technologies);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getAllServiceTypesWithCompletionHandler:(void (^)(NSError *error, NSArray <ServiceType *> *serviceTypes))handler {
   
    [self requestWithPath:@"antenner/tjenester.json" completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSMutableArray <ServiceType *> *serviceTypes = [NSMutableArray array];
            for (NSDictionary *serviceTypeDict in response) {
                NSError *modelError = nil;
                ServiceType *serviceType = [MTLJSONAdapter modelOfClass:ServiceType.class fromJSONDictionary:serviceTypeDict error:&modelError];
                if (!modelError) {
                    [serviceTypes addObject:serviceType];
                }
            }
            
            handler(nil, serviceTypes);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getAntennasWithinRadius:(NSUInteger)radius ofLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate serviceTypeName:(nullable NSString *)serviceTypeName technologyName:(nullable NSString *)technologyName completionHandler:(void (^)(NSError *_Nullable error, NSArray <Antenna *> * _Nullable antennas))handler {

    [self requestWithPath:[NSString stringWithFormat:@"antenner/%f,%f,%lu?tjenesteart=%@&teknologi=%@.json", locationCoordinate.latitude, locationCoordinate.longitude, radius, serviceTypeName, technologyName] completionHandler:^(NSError *error, id response) {
        
        if (!error) {
            NSMutableArray <Antenna *> *antennas = [NSMutableArray array];
            for (NSDictionary *antennaDict in response) {
                NSError *modelError = nil;
                Antenna *antenna = [MTLJSONAdapter modelOfClass:Antenna.class fromJSONDictionary:antennaDict error:&modelError];
                if (!modelError) {
                    [antennas addObject:antenna];
                }
            }
            
            handler(nil, antennas);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getNearestAntennaWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate serviceTypeName:(nullable NSString *)serviceTypeName technologyName:(nullable NSString *)technologyName completionHandler:(void (^)(NSError *error, Antenna *antenna))handler {

    [self requestWithPath:[NSString stringWithFormat:@"antenner/%f,%f?tjenesteart=%@&teknologi=%@.json", locationCoordinate.latitude, locationCoordinate.longitude, serviceTypeName, technologyName] completionHandler:^(NSError *error, id response) {
        if (!error) {
            NSError *modelError = nil;
            Antenna *antenna = [MTLJSONAdapter modelOfClass:Antenna.class fromJSONDictionary:response error:&modelError];
            if (!modelError) {
                handler(nil, antenna);
            } else {
                handler(modelError, nil);
            }
            
        } else {
            handler(error, nil);
        }
    }];
}


+ (void)getAntennasWithPostcode:(NSUInteger)postcode muncipalityId:(NSString *)muncipalityId serviceType:(NSString *)serviceType technology:(NSString *)technology maxCount:(NSUInteger)maxCount completionHandler:(void (^)(NSError *error, NSArray <Antenna *> *antennas))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"antenner.json?postnr=%lu&kommunekode=%@&tjenesteart=%@&teknologi=%@&maxantal=%lu", postcode, muncipalityId, serviceType, technology, maxCount] completionHandler:^(NSError *error, id response) {
        if (!error) {
            NSMutableArray <Antenna *> *antennas = [NSMutableArray array];
            for (NSDictionary *antennaDict in response) {
                NSError *modelError = nil;
                Antenna *antenna = [MTLJSONAdapter modelOfClass:Antenna.class fromJSONDictionary:antennaDict error:&modelError];
                if (!modelError) {
                    [antennas addObject:antenna];
                }
            }
            
            handler(nil, antennas);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getAntennasWithBBox:(BBox)bbox serviceTypeName:(nullable NSString *)serviceTypeName technologyName:(nullable NSString *)technologyName completionHandler:(void (^)(NSError *error, NSArray <Antenna *> *antennas))handler {
    
    [self requestWithPath:[NSString stringWithFormat:@"antenner/%f,%f;%f,%f?tjenesteart=%@&teknologi=%@.json", bbox.southWest.latitude, bbox.southWest.longitude, bbox.northEast.latitude, bbox.northEast.longitude, serviceTypeName, technologyName] completionHandler:^(NSError *error, id response) {
        if (!error) {
            NSMutableArray <Antenna *> *antennas = [NSMutableArray array];
            for (NSDictionary *antennaDict in response) {
                NSError *modelError = nil;
                Antenna *antenna = [MTLJSONAdapter modelOfClass:Antenna.class fromJSONDictionary:antennaDict error:&modelError];
                if (!modelError) {
                    [antennas addObject:antenna];
                }
            }
            
            handler(nil, antennas);
        }
        
        else {
            handler(error, nil);
        }
    }];
}

// ROADS

+ (void)getRoadsWithName:(nonnull NSString *)roadName postcode:(NSUInteger)postcode fromPostcode:(NSUInteger)fromPostcode toPostcode:(NSUInteger)toPostcode muncipalityId:(nullable NSString *)muncipalityId roadId:(nullable NSString *)roadId maxCount:(NSUInteger)maxCount completionHandler:(void (^)(NSError *error, NSArray <Road *> *roads))handler {

    [self requestWithPath:[NSString stringWithFormat:@"vejnavne.json?postnr=%lu&frapostnr=%lu&tilpostnr=%lu&kommunekode=%@&vejnavn=%@&vejkode=%@&maxantal=%lu", postcode, fromPostcode, toPostcode, muncipalityId, roadName, roadId, maxCount] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            NSMutableArray <Road *> *roads = [NSMutableArray array];
            
            for (NSDictionary *rawRoad in response) {
                NSError *modelError = nil;
                Road *road = [MTLJSONAdapter modelOfClass:Road.class fromJSONDictionary:rawRoad error:&modelError];
                if (!modelError) {
                    [roads addObject:road];
                }
            }
            
            handler(nil, roads);
            
        }
        
        else {
            handler(error, nil);
        }
    }];
}

+ (void)getRoadWithId:(nonnull NSString *)roadId muncipalityId:(nullable NSString *)muncipalityId completionHandler:(void (^)(NSError *error, Road *road))handler {

    [self requestWithPath:[NSString stringWithFormat:@"kommuner.json/%@/vejnavne/%@", muncipalityId, roadId] completionHandler:^(NSError *error, id response) {
        if (!error) {
            
            // handler goes here.
            NSError *modelError = nil;
            Road *road = [MTLJSONAdapter modelOfClass:Road.class fromJSONDictionary:response error:&modelError];
            if (!modelError) {
                handler(nil, road);
            }
            
            else {
                handler(modelError, nil);
            }

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
