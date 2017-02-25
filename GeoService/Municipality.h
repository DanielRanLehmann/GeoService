//
//  Municipality.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <MapKit/MapKit.h>
#import <GeoJSONSerialization.h>

@interface Municipality : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSURL *hrefUrl;
@property (nonatomic, copy) NSString *identifier; // or uid
//@property (nonatomic, copy, readonly) NSURL *border;
@property (nonatomic, copy) MKShape *border;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *area; // should be of different type?

@end
