//
//  DNTrackTable.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 26/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNTrackTable.h"

@implementation DNTrackTable

@synthesize trackDelegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSArray*) selectedTracks {
    
    NSMutableArray* res = [NSMutableArray new];
    for (NSDictionary* d in [[trackDelegate arrayController] selectedObjects]) {
        [res addObject:[d valueForKey:@"originalTrack"]];
    }
    
    return res;
    
}

- (void) keyDown:(NSEvent *)theEvent {

    NSUInteger flags = [theEvent modifierFlags] & NSCommandKeyMask;
    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"] && flags == NSCommandKeyMask) {
        // command-e was pressed

        [trackDelegate enqueueTracks:[self selectedTracks]];
        
        
        return;
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"E"] && flags == NSCommandKeyMask) {
        // command-shift-e pressed
        
        [trackDelegate enqueueTracksBottom:[self selectedTracks]];
        return;
    }
    
    [super keyDown:theEvent];
}

@end
