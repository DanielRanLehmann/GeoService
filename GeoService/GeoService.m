//
//  GeoService.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "GeoService.h"

@implementation GeoService

+ (Municipality *)municipalityWithLocation:(CLLocationCoordinate2D)locationCoord {
    
    NSURL *baseUrl = [NSURL URLWithString:@"http://geo.oiorest.dk/"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    [manager GET:[NSString stringWithFormat:@"kommuner/%f,%f.json", locationCoord.latitude, locationCoord.longitude] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSError *error = nil;
        Municipality *municipality = [MTLJSONAdapter modelOfClass:municipality.class fromJSONDictionary:responseObject error:&error];
        NSLog(@"muni model:\n%@", municipality);
        
        //return municipality;
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        //return error;
    }];
    
    return nil;
}

@end
