//
//  DNDurationTransformer.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 25/03/13.
//  Copyright (c) 2013 denknerd.org. All rights reserved.
//

#import "DNDurationTransformer.h"

@implementation DNDurationTransformer

+ (Class)transformedValueClass {
    return [NSString class];
    
}

+ (BOOL)allowsReverseTransformation

{
    
    return NO;
    
}

- (id)transformedValue:(id)value {
    
    
    if (![value isKindOfClass:[NSNumber class]]) {
        return @"-:--";
    }

    NSNumber* n = value;
    NSInteger ti = [n integerValue];
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours > 0) {
        
        return [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
        
    } else {
        
        return [NSString stringWithFormat:@"%li:%02li", (long)minutes, (long)seconds];
        
    }
    
    
}

@end
