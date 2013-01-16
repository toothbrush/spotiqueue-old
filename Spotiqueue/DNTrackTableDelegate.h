//
//  DNTrackTableDelegate.h
//  Spotiqueue
//
//  Created by Paul van der Walt on 26/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DNTrackTableDelegate <NSObject>

- (void) enqueueTracks: (NSArray*) tracks;
- (IBAction)tableDoubleclick:(id)sender tracks:(NSArray*)tracks;
- (void) enqueueTracksBottom: (NSArray*) tracks;
- (IBAction)playOrPause:(id)sender;

@end
