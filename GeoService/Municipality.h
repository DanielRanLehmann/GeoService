//
//  Municipality.h
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Municipality : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *hrefUrl;
@property (nonatomic, copy, readonly) NSString *identifier; // or uid
@property (nonatomic, copy, readonly) NSURL *border;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *area; // should be of different type?

@end
