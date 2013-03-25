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
#import "RSRTVArrayController.h"

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

- (void)copy: (id) sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    
    NSMutableArray * urls = [[NSMutableArray alloc] init];
    
    for (SPTrack* d  in [self selectedTracks]) {
        if (d && d.spotifyURL) {
            [urls addObject:d.spotifyURL];
        }

    }
    
    [pasteBoard writeObjects:urls];
    // some code to put data on the pasteBoard
    
    [urls release];
}

- (void) paste: (id) sender {
    // uh oh
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];

    NSArray* a = [[pasteBoard stringForType:NSStringPboardType] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString* pastedURL in a) {
        if (pastedURL && ![pastedURL isEqualToString:@""]) {
            [self.trackDelegate pasteURLString:pastedURL sender:self];
        }
    }
    
    
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
    
    //    DLog(@"pfff. asking for selected tracks. %@", relatedArrayController);
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
    
    DLog(@"key event = %@", theEvent);
    NSUInteger flags = [theEvent modifierFlags] & (NSCommandKeyMask | NSShiftKeyMask);
    
    if ([theEvent keyCode] == 124 &&
        flags == NSCommandKeyMask) {
        // command-right was pressed: browse album.
        
        if ([self.selectedTracks count] == 1) {
            
            SPTrack* t = [self.selectedTracks objectAtIndex:0];
            if (t) {
                SPAlbum* a = t.album;
                [self.trackDelegate triggerAlbumBrowse:a sender:self];
            }
        }
    
        
    } else if ([theEvent keyCode] == 123 &&
        flags == NSCommandKeyMask) {
        // command-left was pressed
        [self enqueuetrack:nil];
        
    } else if ([theEvent keyCode] == 123 &&
               flags == (NSCommandKeyMask | NSShiftKeyMask)) {
        // command-shift-left pressed
        // we also still support e and friends
        [self enqueuetrackTop:nil];
        
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"] &&
               flags == NSCommandKeyMask) {
        // command-e was pressed
        [self enqueuetrack:nil];
        
    } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"E"] &&
               flags == (NSCommandKeyMask | NSShiftKeyMask)) {
        // command-shift-e pressed
        // we also still support e and friends
        [self enqueuetrackTop:nil];
        
    } else if ([theEvent keyCode] == 117 ||
               [theEvent keyCode] == 51) {
        // delete or backspace
        [self deleteOrBackspace:nil];
        
    } else if ([theEvent keyCode] == 36) { // enter key
        // lets fire the doubleclick action here.
        [self enter:nil];
        
    } else if ([theEvent keyCode] == 49) { // space bar
        //space was pressed
        [self.trackDelegate playOrPause:nil];
        
    } else if ([[[theEvent characters] lowercaseString] isEqualToString:@"d"] ) {
        
        [self deleteOrBackspace:nil];
    } else if([[[theEvent characters] lowercaseString] isEqualToString:@"j"]) { // down
        
        if ([theEvent modifierFlags] & NSCommandKeyMask) {
            // okay, we actually want to MOVE these rows
            NSIndexSet* s=[self.relatedArrayController moveObjectsInArrangedObjectsFromIndexes:self.selectedRowIndexes toIndex:[self.selectedRowIndexes lastIndex]+2]; // plus 2 because inserting at original index+1 makes no change

            [self selectRowIndexes:s byExtendingSelection:NO];
        } else {
            // vanilla behaviour
            NSEvent* synthetic = [NSEvent keyEventWithType:NSKeyDown location:NSPointFromCGPoint(CGPointZero) modifierFlags:[theEvent modifierFlags] timestamp:0 windowNumber:0 context:nil characters:@"" charactersIgnoringModifiers:@"" isARepeat:NO keyCode:125];
            
            [super keyDown:synthetic];
        }
      
    } else if([[[theEvent characters] lowercaseString] isEqualToString:@"k"]) { // up

        if ([theEvent modifierFlags] & NSCommandKeyMask) {
            // okay, we actually want to MOVE these rows
            NSIndexSet* s=[self.relatedArrayController moveObjectsInArrangedObjectsFromIndexes:self.selectedRowIndexes toIndex:[self.selectedRowIndexes firstIndex]-1];
            [self selectRowIndexes:s byExtendingSelection:NO];
        } else {
            // vanilla behaviour
            NSEvent* synthetic = [NSEvent keyEventWithType:NSKeyDown location:NSPointFromCGPoint(CGPointZero) modifierFlags:[theEvent modifierFlags] timestamp:0 windowNumber:0 context:nil characters:@"" charactersIgnoringModifiers:@"" isARepeat:NO keyCode:126];
            
            [super keyDown:synthetic];
        }
    } else if([[[theEvent characters] lowercaseString] isEqualToString:@"g"]) {

        NSInteger numRows = [self numberOfRows];
        
        if ([theEvent modifierFlags] & NSShiftKeyMask) {
            // go to bottom
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:numRows-1]
              byExtendingSelection:NO];
            [self scrollToEndOfDocument:nil];
        } else {
            // go to top
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
              byExtendingSelection:NO];
            [self scrollToBeginningOfDocument:nil];
        }
    } else if ([theEvent keyCode] == 123) { // left arrow
        
        // select queue
        [self.trackDelegate focusQueue:self];

    } else if ([theEvent keyCode] == 124) { //right arrow
        // select search view
        [self.trackDelegate focusSearchResults:self];
    } else if ([theEvent keyCode] == 126 &&
               flags & NSCommandKeyMask) { // up arrow with cmd
        // okay, we actually want to MOVE these rows
        DLog(@"command-shift-arrow?");
        NSIndexSet* s=[self.relatedArrayController moveObjectsInArrangedObjectsFromIndexes:self.selectedRowIndexes toIndex:[self.selectedRowIndexes firstIndex]-1];
        [self selectRowIndexes:s byExtendingSelection:NO];
    } else if ([theEvent keyCode] == 125 &&
               flags & NSCommandKeyMask) { // down arrow with cmd
        // okay, we actually want to MOVE these rows
        NSIndexSet* s=[self.relatedArrayController moveObjectsInArrangedObjectsFromIndexes:self.selectedRowIndexes toIndex:[self.selectedRowIndexes lastIndex]+2]; // plus 2 because inserting at original index+1 makes no change
        
        [self selectRowIndexes:s byExtendingSelection:NO];

    }
    else {
        
        [super keyDown:theEvent];
    }
}

@end
