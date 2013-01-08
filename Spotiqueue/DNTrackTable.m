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
    
    NSMutableArray* res = [NSMutableArray new];
    for (NSDictionary* d in [[trackDelegate arrayController] selectedObjects]) {
        [res addObject:[d valueForKey:@"originalTrack"]];
    }
    
    return res;
    
}

- (void) keyDown:(NSEvent *)theEvent {

   
    NSLog(@"key event = %@", theEvent);
    NSUInteger flags = [theEvent modifierFlags] & NSCommandKeyMask;
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"] && flags == NSCommandKeyMask) {
        // command-e was pressed

        [trackDelegate enqueueTracksBottom:[self selectedTracks]];
        
        
        return;
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"E"] && flags == NSCommandKeyMask) {
        // command-shift-e pressed
        
        [trackDelegate enqueueTracks:[self selectedTracks]];
        return;
    } else if (key == NSDeleteCharacter) {

        if([self selectedRow] == -1)
        {
            NSBeep();
        }
        [self.relatedArrayController remove:nil];
        
        return;
    } else if ([theEvent keyCode] == 36) {
        // lets fire the doubleclick action here.
        NSLog(@"enter pressed. obj = %@", self.selectedTracks);
        
        if(self.selectedTracks != nil) {
            if ([self.selectedTracks objectAtIndex:0] != nil) {
                [self.trackDelegate tableDoubleclick:[NSMutableDictionary dictionaryWithObject:[self.selectedTracks objectAtIndex:0] forKey:@"payload"]];
//                [self performSelector:self.doubleAction withObject:[NSMutableDictionary dictionaryWithObject:[self.selectedTracks objectAtIndex:0] forKey:@"payload"]];

            }
        }
    
    }
    
    [super keyDown:theEvent];
}

@end
