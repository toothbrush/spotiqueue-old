//
//  DNApplication.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 23/01/2013.
//  Copyright (c) 2013 denknerd.org. All rights reserved.
//

#import "DNApplication.h"

@implementation DNApplication




- (void)sendEvent:(NSEvent *)theEvent {

    if ([theEvent type] != NSKeyDown) {
        [super sendEvent:theEvent];
        return;
    }

    NSUInteger mods = [theEvent modifierFlags] & NSCommandKeyMask;

    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"l"] &&
        mods == NSCommandKeyMask) {
        // okay we have l here, so fire apple-f instead.

        NSEvent* synthetic = [NSEvent keyEventWithType:NSKeyDown location:NSPointFromCGPoint(CGPointZero) modifierFlags:NSCommandKeyMask timestamp:0 windowNumber:0 context:nil characters:@"f" charactersIgnoringModifiers:@"f" isARepeat:NO keyCode:0];
        [super sendEvent:synthetic];
        
    } else {
        [super sendEvent:theEvent];
    }
}

@end
