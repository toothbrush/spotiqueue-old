//
//  DNTrackTable.h
//  Spotiqueue
//
//  Created by Paul van der Walt on 26/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DNTrackTableDelegate.h"

@interface DNTrackTable : NSTableView



- (NSArray*) selectedTracks;


@property (assign) id<DNTrackTableDelegate> trackDelegate;

@end
