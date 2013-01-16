//
//  DNSearchField.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 16/01/2013.
//  Copyright (c) 2013 denknerd.org. All rights reserved.
//

#import "DNSearchField.h"

@implementation DNSearchField

- (BOOL)resignFirstResponder {
    self.backgroundColor = [NSColor whiteColor];
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    self.backgroundColor = [NSColor colorWithSRGBRed:187.0/255.0f green:202.0/255.0f blue:1.0f alpha:0.4f];
    return [super becomeFirstResponder];
}

@end
