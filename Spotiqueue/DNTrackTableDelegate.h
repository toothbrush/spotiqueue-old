//
//  DNTrackTableDelegate.h
//  Spotiqueue
//
//  Created by Paul van der Walt on 26/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPArtist;
@class SPAlbum;
@protocol DNTrackTableDelegate <NSObject>

- (void) enqueueTracks: (NSArray*) tracks;
- (IBAction)tableDoubleclick:(id)sender tracks:(NSArray*)tracks;
- (void) enqueueTracksBottom: (NSArray*) tracks;
- (IBAction)playOrPause:(id)sender;

- (void) focusQueue:(id)sender;
- (void) focusSearchResults:(id)sender;

- (void) triggerArtistBrowse:(SPArtist*)artist sender:(id) sender;
- (void) triggerAlbumBrowse:(SPAlbum*)album sender:(id) sender;

@end
