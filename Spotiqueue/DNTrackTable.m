//
//  DNTrackTable.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 26/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNTrackTable.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import <CoreServices/CoreServices.h>

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
    __strong NSMutableArray* res = [[NSMutableArray alloc] init];
    for (id d in [relatedArrayController selectedObjects]) {
        [res addObject:[d valueForKey:@"originalTrack"]];
    }
    
    return [res autorelease];
    
}

- (void) enqueuetrack: (id) sender {
    [trackDelegate enqueueTracksBottom:[self selectedTracks]];
}

- (void) enqueuetrackTop: (id) sender {
    [trackDelegate enqueueTracks:[self selectedTracks]];
}

- (BOOL)resignFirstResponder {
    
    SInt32 major = 0;
    SInt32 minor = 0;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    
    if (major == 10 && minor <= 6) {
        self.usesAlternatingRowBackgroundColors = NO;
    } else {
        self.backgroundColor = [NSColor whiteColor];
    }
    
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    
    SInt32 major = 0;
    SInt32 minor = 0;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    
    if (major == 10 && minor <= 6) {
        self.usesAlternatingRowBackgroundColors = YES;
    } else {
         self.backgroundColor = [NSColor colorWithSRGBRed:187.0/255.0f green:202.0/255.0f blue:1.0f alpha:0.4f];
    }
    return [super becomeFirstResponder];
}

- (void) deleteOrBackspace: (id) sender {
    
    if([self selectedRow] == -1)
    {
        NSBeep();
    }
    if (self.relatedArrayController.isEditable) {
        [self.relatedArrayController removeObjects:self.relatedArrayController.selectedObjects];
        
    }
    
}

- (void) enter: (id) sender {
    
    if(self.selectedTracks != nil) {
        
        [self.trackDelegate tableDoubleclick:self tracks: self.selectedTracks];
        
    }
    
}

- (void) keyDown:(NSEvent *)theEvent {
    
    //    NSLog(@"key event = %@", theEvent);
    NSUInteger flags = [theEvent modifierFlags] & (NSCommandKeyMask | NSShiftKeyMask);
    
    if ([theEvent keyCode] == 123 && flags == NSCommandKeyMask) {
        // command-left was pressed
        [self enqueuetrack:nil];
        
    } else if ([theEvent keyCode] == 123 && flags == (NSCommandKeyMask | NSShiftKeyMask)) {
        // command-shift-left pressed
        // we also still support e and friends
        [self enqueuetrackTop:nil];
        
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"] && flags == NSCommandKeyMask) {
        // command-left was pressed
        [self enqueuetrack:nil];
        
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"E"] && flags == (NSCommandKeyMask | NSShiftKeyMask)) {
        // command-shift-left pressed
        // we also still support e and friends
        [self enqueuetrackTop:nil];
        
    } else if ([theEvent keyCode] == 117 || [theEvent keyCode] == 51) {
        // delete or backspace
        [self deleteOrBackspace:nil];
        
    } else if ([theEvent keyCode] == 36) {
        // lets fire the doubleclick action here.
        [self enter:nil];
        
    } else if ([theEvent keyCode] == 49) {
        //space was pressed
        [self.trackDelegate playOrPause:nil];
        
    } else {
        
        [super keyDown:theEvent];
    }
}

@end
