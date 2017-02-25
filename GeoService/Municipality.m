//
//  Municipality.m
//  GeoService
//
//  Created by Daniel Ran Lehmann on 2/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Municipality.h"

@implementation Municipality

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"hrefUrl" : @"href",
             @"identifier" : @"nr",
             @"name" : @"navn",
             @"area" : @"areal",
             @"border" : @"grænse"
             };
}

// setters goes here for all readonly properties.

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"hrefUrl"] || [key isEqualToString:@"borderUrl"]) {
        
        if ([key isEqualToString:@"borderUrl"]) {
            
            return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
                if (success) {
                    // try converting borderUrl --> to name of just 'border' and make it an MKShape.
                    NSString *urlEncodedString  = [self urlencodeString:str];
                    return [NSURL URLWithString:urlEncodedString];
                }else{
                    return @"";
                }
                
            }];
        }
        
        //return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                NSString *urlEncodedString  = [self urlencodeString:str];
                return [NSURL URLWithString:urlEncodedString];
            }else{
                return @"";
            }
            
        }];
    }
    
    return nil;
}

+ (NSString *)urlencodeString:(NSString*)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end
