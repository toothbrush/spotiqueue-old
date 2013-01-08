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
@synthesize relatedArrayController;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
    
    if (!self.relatedArrayController.isEditable) {
        return NSDragOperationNone;
    }
    
    if (flag) {
        return NSDragOperationMove;

    } else {
        // operation is from outside my app
        return NSDragOperationNone;
    }
}

- (NSArray*) selectedTracks {
    
//    NSLog(@"pfff. asking for selected tracks. %@", relatedArrayController);
    __strong NSMutableArray* res = [NSMutableArray new];
    for (id d in [relatedArrayController selectedObjects]) {
        [res addObject:[d valueForKey:@"originalTrack"]];
    }
    
    return res;
    
}

- (void) keyDown:(NSEvent *)theEvent {

   
    NSLog(@"key event = %@", theEvent);
    NSUInteger flags = [theEvent modifierFlags] & NSCommandKeyMask;

    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"] && flags == NSCommandKeyMask) {
        // command-e was pressed

        [trackDelegate enqueueTracksBottom:[self selectedTracks]];
        
        
        return;
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"E"] && flags == NSCommandKeyMask) {
        // command-shift-e pressed
        
        [trackDelegate enqueueTracks:[self selectedTracks]];
        return;
    } else if ([theEvent keyCode] == 117 || [theEvent keyCode] == 51) {

        // delete or backspace

        if([self selectedRow] == -1)
        {
            NSBeep();
        }
        if (self.relatedArrayController.isEditable) {
            [self.relatedArrayController removeObjects:self.relatedArrayController.selectedObjects];

        }
        
        return;
    } else if ([theEvent keyCode] == 36) {
        // lets fire the doubleclick action here.

        if(self.selectedTracks != nil) {

            [self.trackDelegate tableDoubleclick: self.selectedTracks];

        }
        return;
    
    } 
    
    [super keyDown:theEvent];
}

@end
