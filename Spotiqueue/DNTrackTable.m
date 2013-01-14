//
//  DNTrackTable.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 26/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNTrackTable.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>

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

- (void) appleE: (id) sender {
    [trackDelegate enqueueTracksBottom:[self selectedTracks]];
}

- (void) appleShiftE: (id) sender {
    [trackDelegate enqueueTracks:[self selectedTracks]];
}

- (void) enqueueAlbum: (id) sender {
    if ([self.selectedTracks count] > 0) {
//        
//        SPTrack* t = [self.selectedTracks objectAtIndex:0];
//        SPAlbumBrowse* ab = [[SPAlbumBrowse alloc] initWithAlbum:t.album inSession:[SPSession sharedSession]];
//        
//        
//        [trackDelegate enqueueTracksBottom:ab.tracks];
//        

    }
    
}
- (void) enqueueAlbumTop: (id) sender {
    if ([self.selectedTracks count] > 0) {
        
//        SPTrack* t = [self.selectedTracks objectAtIndex:0];
//        SPAlbumBrowse* ab = [[SPAlbumBrowse alloc] initWithAlbum:t.album inSession:[SPSession sharedSession]];
//        
//        
//        [trackDelegate enqueueTracks:ab.tracks];
//        
        
    }
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
    NSUInteger flags = [theEvent modifierFlags] & NSCommandKeyMask;

    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"] && flags == NSCommandKeyMask) {
        // command-e was pressed
        [self appleE:nil];
        return;
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"E"] && flags == NSCommandKeyMask) {
        // command-shift-e pressed
        [self appleShiftE:nil];
        return;
    }
    /* else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"s"] && flags == NSCommandKeyMask) {
        [self enqueueAlbum:nil];
        return;
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"S"] && flags == NSCommandKeyMask) {
        [self enqueueAlbumTop:nil];
        return;
    } */
    else if ([theEvent keyCode] == 117 || [theEvent keyCode] == 51) {
        // delete or backspace
        [self deleteOrBackspace:nil];
        return;
    } else if ([theEvent keyCode] == 36) {
        // lets fire the doubleclick action here.
        [self enter:nil];
        return;
    
    } 
    
    [super keyDown:theEvent];
}

@end
