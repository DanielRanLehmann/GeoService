//
//  GeoserviceV2.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 3/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "GeoserviceV2.h"
#import <AFNetworking/AFNetworking.h>

static NSString *baseURL = @"https://services.kortforsyningen.dk/";

@interface GeoserviceV2 ()

@property (copy, nonatomic) NSString *login;
@property (copy, nonatomic) NSString *password;

@end

@implementation GeoserviceV2

- (instancetype)initWithLogin:(NSString *)login password:(NSString *)password {

    self = [super init];
    if (self) {
        
        _login = login;
        _password = password;
    }
    
    return self;
}

- (void)GET:(GSMethodTypes)methodType parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error, id response))handler {

    NSString *methodName = [self methodNameWithType:methodType];
    
    // what about the order?
    NSMutableDictionary *updatedParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    updatedParams[@"servicename"] = @"RestGeokeys_v2";
    updatedParams[@"method"] = methodName;
    
    updatedParams[@"login"] = _login;
    updatedParams[@"password"] = _password;
    
    //NSURL *baseUrl = [NSURL URLWithString:baseURL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:baseURL parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        handler(nil, responseObject);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        handler(error, nil);
    }];
}

#pragma mark - Helpers
- (NSString *)methodNameWithType:(GSMethodTypes)methodType {
    
    NSString *methodName;
    switch (methodType) {
        case GSMethodTypeAddress:
            methodName = @"adresse";
            break;
            
        case GSMethodTypePAddress:
            methodName = @"padresse";
            break;
            
        case GSMethodTypeNAddress:
            methodName = @"nadresse";
            break;
            
        case GSMethodTypeRoad:
            methodName = @"vej";
            break;
            
        case GSMethodTypePostalCode:
            methodName = @"postdistrikt";
            break;
            
        case GSMethodTypeMunicipality:
            methodName = @"kommune";
            break;
            
        case GSMehtodTypeParish:
            methodName = @"sogn";
            break;
            
        case GSMethodTypePoliceDistrict:
            methodName = @"politikreds";
            break;
            
        case GSMethodTypeConstituency:
            methodName = @"opstillingskreds";
            break;
            
        case GSMethodTypeJurisdiction:
            methodName = @"retskreds";
            break;
            
        case GSMethodTypeOwnerAssociations:
            methodName = @"ejerlav";
            break;
            
        case GSMethodTypeLandRegisterNumber:
            methodName = @"matrikelnr";
            break;
            
        case GSMethodTypeAssessingProperty:
            methodName = @"vurderingsejendom";
            break;
            
        case GSMethodTypeRealEstate:
            methodName = @"sfeejendom";
            break;
            
        case GSMethodTypePlace:
            methodName = @"stedv2";
            break;
            
        case GSMethodTypePlaceCategory:
            methodName = @"stedkat";
            break;
            
        case GSMethodTypeHeight:
            methodName = @"hoejde";
            break;
    }
    
    return methodName;
}


@end
