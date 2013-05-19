//
//  DNAppDelegate.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 22/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNAppDelegate.h"
#import <Growl/Growl.h>
#import "DNDurationTransformer.h"

@implementation DNAppDelegate

@synthesize persistentStoreCoordinator    = _persistentStoreCoordinator;
@synthesize managedObjectModel            = _managedObjectModel;
@synthesize managedObjectContext          = _managedObjectContext;
@synthesize nextButton;
@synthesize aboutText;
@synthesize playbackProgressSlider;
@synthesize aboutWindow;
@synthesize searchResults;
@synthesize userNameField, previousSong;

@synthesize passwordField;
@synthesize lfmPasswordField, lfmUserNameField;
@synthesize playlistSelectionMenu;
@synthesize loginProgress;

@synthesize savePassword, searchIndicator;
@synthesize loadPlaylistSheet, easyScrobble;
@synthesize loginSheet, searchField;
@synthesize window = _window;
@synthesize playbackManager;
@synthesize search;
@synthesize queueTable;
@synthesize searchArrayController, queueArrayController;


- (void)triggerAlbumBrowse:(SPAlbum*)album sender:(id)sender {
    
    SPAlbumBrowse* ab = [SPAlbumBrowse browseAlbum:album
                                         inSession:[SPSession sharedSession]];
    
    [SPAsyncLoading waitUntilLoaded:ab
                            timeout:10.0f
                               then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                   SPAlbumBrowse* abl = [loadedItems objectAtIndex:0];
                                   if (abl==nil) {
                                       return;
                                   }
                                   
                                   [self populateSearchTable:abl.tracks];
                               }];
}

- (void)focusQueue:(id)sender {
    
    if ([self.window firstResponder] == self.queueTable) {
        return;
    }
    [self.window.firstResponder resignFirstResponder];
    [self.window makeFirstResponder:self.queueTable];
}

- (void)focusSearchResults:(id)sender {
    if ([self.window firstResponder] == self.searchResults) {
        return;
    }
    [self.window.firstResponder resignFirstResponder];
    [self.window makeFirstResponder:self.searchResults];
    
}


- (IBAction)tableDoubleclick:(id)sender tracks:(NSArray*)tracks {
    
    if ([tracks isKindOfClass:[NSArray class]]) {
        if ([tracks count] == 1) {
            id played = nil;
            if ([[tracks objectAtIndex:0] isKindOfClass:[SPTrack class]]) {
                // we have a track...
                played = [tracks objectAtIndex:0];
                [self playSPTrack: played];
            } else {
                // not a track, try extracting from dictionary
                if ([[tracks objectAtIndex:0] isKindOfClass:[NSMutableDictionary class]]) {
                    id item = [[tracks objectAtIndex:0] objectForKey:@"originalTrack"];
                    if (item) {
                        if ([item isKindOfClass:[SPTrack class]]) {
                            // here we have a track again
                            played = item;
                            [self playSPTrack:played];
                        }
                    }
                }
            }
            if (sender == self.queueTable) {
                // we should remove stuff above this entry.
                
                while (![[[self.queueArrayController.content objectAtIndex:0] objectForKey:@"originalTrack"] isEqual: played]) {
                    
                    [self.queueArrayController removeObjectAtArrangedObjectIndex:0];
                }
                // finally remove the clicked track:
                [self.queueArrayController removeObjectAtArrangedObjectIndex:0];
                
                
                [self.queueTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];

                [self.queueTable reloadData];

                [self.queueTable scrollToBeginningOfDocument:nil];
                


            }
        } else if ([tracks count] > 1) {
            // the user pressed enter on a whole bunch of tracks.
            if ([self.queueArrayController.content count] == 0) {
                // the queue is empty now, so we assume the user means to play the whole lot
                
                [self enqueueTracksBottom:tracks];
                
                if (playbackManager.currentTrack == nil) {
                    [self playNextTrack:nil];
                }

            } else {
                // just enqueue, don't play-next.
                [self enqueueTracksBottom:tracks];

            }
        }
    }
}


- (NSString *)trackDuration {
    
    if (self.playbackManager.currentTrack == nil) {
        return @"-:--";
    }
    
    NSTimeInterval t = self.playbackManager.currentTrack.duration;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t];

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];

    return formattedDate;
}

- (void) enqueueTracksBottom:(NSArray *)tracks {
    
    NSMutableDictionary* value;
    for (SPTrack* t in tracks) {
        value = [[NSMutableDictionary alloc] init];
        [value setObject:t.name forKey:@"name"];
        [value setObject:[[t.artists objectAtIndex:0] name] forKey:@"artist"];
        [value setObject:t.album.name forKey:@"album"];
        [value setObject:t forKey:@"originalTrack"];
        
        [value setObject:[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] forKey:@"whenAdded"];
        
        [queueArrayController addObject:value];
        [value release];
    }
    
    [self.queueTable scrollToEndOfDocument:nil];
}

- (void) enqueueTracks:(NSArray *)tracks {
    
    NSMutableDictionary* value;
    NSEnumerator *enumerator = [tracks reverseObjectEnumerator];
    for (SPTrack* t in enumerator) {
        value = [[NSMutableDictionary alloc] init];
        [value setObject:t.name forKey:@"name"];
        [value setObject:[[t.artists objectAtIndex:0] name] forKey:@"artist"];
        [value setObject:t.album.name forKey:@"album"];
        [value setObject:t forKey:@"originalTrack"];
        
        [value setObject:[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] forKey:@"whenAdded"];
        
        [queueArrayController insertObject:value atArrangedObjectIndex:0];
        [value release];
    }

    [self.queueTable scrollToBeginningOfDocument:nil];
}
- (IBAction)playOrPause:(id)sender {
    
    if (self.playbackManager.currentTrack != nil) {
        self.playbackManager.isPlaying = !self.playbackManager.isPlaying;
    }
    
}


- (IBAction)searched:(id)sender{
    
    self.search = nil;
    
    NSString* searchTerm = [[self.searchField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (searchTerm == nil || [searchTerm isEqualToString:@""]) {
        [self.searchIndicator stopAnimation:nil];
        return;
    }
    
    if ([searchTerm hasPrefix:@"spotify:"]) {
        [self dealWithSomeURL:searchTerm];

        [self.searchIndicator stopAnimation:nil];
        
    } else {
        
        self.search = [[SPSearch searchWithSearchQuery:searchTerm
                                             inSession:[SPSession sharedSession]] retain];
        [self.searchIndicator startAnimation:nil];
        
        [self addObserver:self forKeyPath:@"search.tracks" options:0 context:nil];
        
        [self.searchResults setSortDescriptors: self.tracksSortDescriptors];
    }
    
    [sender resignFirstResponder];
    [self.window makeFirstResponder:self.searchResults];
}

- (void)dealloc {
    self.playbackManager = nil;
    self.playlistSelectionMenu = nil;

    self.easyScrobble = nil;
    self.loginSheet = nil;
    self.aboutText = nil;
    self.previousSong = nil;

    self.aboutWindow = nil;
    self.loadPlaylistSheet = nil;
    self.window = nil;
    
    [super dealloc];
}

- (void)showAbout:(id)sender {
    [self.aboutText
     readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Credits"
                                                      ofType:@"rtf"]];
    
    [self.aboutWindow center];
    [self.aboutWindow makeKeyAndOrderFront:nil];
    
    
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    
    DNDurationTransformer* dt = [[[DNDurationTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer:dt
                                    forName:@"DNDurationTransformer"];
    
    
#include "SpotifySecrets.h"
    
	NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:sizeof(g_appkey)]
											   userAgent:@"org.denknerd.Spotiqueue"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
    
	if (error != nil) {
		DLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    
	[[SPSession sharedSession] setDelegate:self];
	self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    
	[_window center];
	[_window orderFront:nil];
   
    [self.searchResults setRelatedArrayController:self.searchArrayController];
    [self.queueTable setRelatedArrayController:self.queueArrayController];
    [self.searchResults setTrackDelegate:self];
    [self.queueTable setTrackDelegate:self];
    
    
    NSArray *accounts = [SSKeychain accountsForService:kServiceName];
    NSArray *accountsLFM = [SSKeychain accountsForService:kServiceNameLFM];

    if (accounts != nil) {
        [passwordField setStringValue:[SSKeychain passwordForService:kServiceName account:[[accounts objectAtIndex:[accounts count]-1] valueForKey:@"acct"]]];
        [userNameField setStringValue:[[accounts objectAtIndex:[accounts count]-1] valueForKey:@"acct"]];
    }
    if (accountsLFM != nil) {
        [lfmPasswordField setStringValue:[SSKeychain passwordForService:kServiceNameLFM account:[[accountsLFM objectAtIndex:[accountsLFM count]-1] valueForKey:@"acct"]]];
        [lfmUserNameField setStringValue:[[accountsLFM objectAtIndex:[accountsLFM count]-1] valueForKey:@"acct"]];

    }
    
    

}



- (NSArray *)tracksSortDescriptors {
    /* bonus bug:
     do not refer to referred objects, like originalTrack.discNumber.
     they probably get released, at which point stuff starts breaking.
     */
    return [NSArray arrayWithObjects:
            [NSSortDescriptor sortDescriptorWithKey:@"discNumber"
                                          ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"artist"
                                          ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"albumURL"
                                          ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"trackNumber"
                                          ascending:YES],
            nil];
}

- (IBAction)toggleFullScreen:(id)sender {
    if ([self.window respondsToSelector:@selector(toggleFullScreen:)]) {
        [self.window toggleFullScreen:nil];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
#ifdef DEBUG
    
    [[SPSession sharedSession] flushCaches:^{
        DLog(@"libSpotify caches flushed.");
    }];
    
#endif
    
    [GrowlApplicationBridge setGrowlDelegate:@""]; // ugh, work around Growl bug.
    
	[self addObserver:self
		   forKeyPath:@"playbackManager.trackPosition"
			  options:0
			  context:nil];
    
    [self addObserver:self
		   forKeyPath:@"playbackManager.currentTrack"
			  options:0
			  context:nil];
    [self addObserver:self
           forKeyPath:@"queueArrayController.arrangedObjects"
              options:0
              context:nil];
    
	[NSApp beginSheet:self.loginSheet
	   modalForWindow:self.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
    
    
    [self.searchArrayController setDraggingEnabled:NO];
    self.easyScrobble = [[LPEasyScrobble alloc] init];
    
    [self.searchResults setSortDescriptors: self.tracksSortDescriptors];
    [self.searchIndicator stopAnimation:nil];
    
    [self.searchField becomeFirstResponder];
        
}
- (void) insertPlaylistIntoSearchResultsBy:(NSURL*) url {
    [SPPlaylist playlistWithPlaylistURL:url
                              inSession:[SPSession sharedSession]
                               callback:^(SPPlaylist *playlist) {
                                   
                                   if (playlist == nil) {
                                       return;
                                   }
                                   
                                   [SPAsyncLoading waitUntilLoaded:playlist
                                                           timeout:20.0f
                                                              then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                                                  
                                                                  SPPlaylist* loaded = [loadedItems objectAtIndex:0];
                                                                  [self populateSearchTable:loaded.items];
                                                                  
                                                              }];
                               }];

}

- (void) insertAlbumByURL: (NSURL*) url {
 
    [SPAlbum albumWithAlbumURL:url
                     inSession:[SPSession sharedSession]
                      callback:^(SPAlbum *album) {
                          if (album == nil) {
                              return;
                          }
                         
                          SPAlbumBrowse* ab = [SPAlbumBrowse browseAlbum:album
                                           inSession:[SPSession sharedSession]];
                          [SPAsyncLoading waitUntilLoaded:ab
                                                  timeout:10.0f
                                                     then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                                         SPAlbumBrowse* a = [loadedItems objectAtIndex:0];
                                                        
                                                         [self populateSearchTable:a.tracks];
                                                         
                                                     }];
                      }];
}

- (void)loadStarredTracks:(id)sender {
    SPPlaylist* p = [[SPSession sharedSession] starredPlaylist];
    
    [SPAsyncLoading waitUntilLoaded:p
                            timeout:10.0f
                               then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                   SPPlaylist* starred = [loadedItems objectAtIndex:0];
                                   if (starred == nil) {
                                       return;
                                   }
     [self populateSearchTable:starred.items];
                               }];
    [self cancelLoadURLSheet:nil];
}

- (void)loadPlaylistFromURL:(id)sender {
    
    SPPlaylistContainer* playlists = [[SPSession sharedSession] userPlaylists];
    
    
    NSString* playlistname = [self.playlistSelectionMenu selectedItem].title;
    DLog(@"looking for playlist: \"%@\"", playlistname);
    
    NSURL* result = nil;
    
    for (id p  in playlists.playlists) {
        if ([[p name] isEqualToString:playlistname]) {
            result = [p spotifyURL];
            break;
        }
    }
    
    if (result == nil) {
        NSBeep();
        DLog(@"hm, playlist not found.");
        return;
    }
    
    DLog(@"found %@", result);
    [self insertPlaylistIntoSearchResultsBy:result];
    
    [self cancelLoadURLSheet:nil];

}

- (void)pasteURLString:(NSString *)stringURL sender:(id)sender {
    [self dealWithSomeURL:stringURL];
}
- (void) dealWithSomeURL:(NSString*) stringURL {
    
    NSURL* u = [NSURL URLWithString:[stringURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    DLog(@"opening url = %@", u);
    SPDispatchAsync(^{
        id thing = [[SPSession sharedSession]
                    objectRepresentationForSpotifyURL:u
                    linkType:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([thing isKindOfClass:[SPTrack class]]) {
                DLog(@"SPTrack was given. %@", thing);
                
                [SPAsyncLoading waitUntilLoaded:thing
                                        timeout:5.0f
                                           then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                               [self enqueueTracksBottom:loadedItems];
                                               
                                           }];
                
                
            } else if ([thing isKindOfClass:[SPAlbum class]]) {
                DLog(@"SPAlbum was given. %@", thing);
                [self insertAlbumByURL:u];
                
                
            } else if ([thing isKindOfClass:[SPPlaylist class]]) {
                DLog(@"SPPlaylist was given. %@", thing);
                
                [self insertPlaylistIntoSearchResultsBy:u];
                
            } else {
                DLog(@"Unsupported URL provided: \"%@\"", u);
            }
        });
    });
    

}

- (void)playlist:(SPPlaylist *)aPlaylist willAddItems:(NSArray *)items atIndexes:(NSIndexSet *)theseIndexesArentYetValid {
    DLog(@"willAddItems: %@", items);

}
- (void)playlist:(SPPlaylist *)aPlaylist didAddItems:(NSArray *)items atIndexes:(NSIndexSet *)newIndexes {
    DLog(@"didAddItems: %@", items);
}

- (void)showLoadPlaylist:(id)sender {
    
    if (![[SPSession sharedSession] user]) {
        return;
    }
    
    [NSApp beginSheet:self.loadPlaylistSheet
	   modalForWindow:self.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];

    
    SPPlaylistContainer* c = [[SPSession sharedSession] userPlaylists];

    [SPAsyncLoading waitUntilLoaded:c
                            timeout:20.0
                               then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                   
                                   [self.playlistSelectionMenu removeAllItems];
                                   
                                   
                                   for (id p in [[loadedItems objectAtIndex:0] playlists]) {
                                       if ([p isKindOfClass:[SPPlaylist class]]) {
                                           
                                           [SPAsyncLoading waitUntilLoaded:p
                                                                   timeout:5.0
                                                                      then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                                                          
                                                                          if (![loadedItems count]<1) {
                                                                              DLog(@"loaded playlist %@", [loadedItems objectAtIndex:0]);
                                                                              SPPlaylist* pp = [loadedItems objectAtIndex:0];
                                                                              [self.playlistSelectionMenu addItemWithTitle: [pp name]];

                                                                          }
                                                                      }];
                                           
                                       } else if ([p isKindOfClass:[SPPlaylistFolder class]]) {
                                           // maybe handle playlist folders later. bleh.
                                       }

                                       
                                       
                                   }
                               }];
    
    
    
    // a track:
    // spotify:track:0If1Jxo7CjpTsKLz3aXmqW
    
    // a playlist:
    // spotify:user:toothbrush666:playlist:0CGju5c3vrhBVTxQVTFgqS
    // someone else:
    // spotify:user:118172757:playlist:2acS52TIUt8cDzPPhv5qQn
    
    // an album:
    // spotify:album:0YSgqHce1ofZINjVas1D4v

}

- (void) addTrackToSearchResults: (id)tr {
    
    if (tr == nil) {
        return;
    }
    if (![tr isKindOfClass:[SPTrack class]]) {
        return;
    }
    SPTrack* t = tr;
  
    if (!t.isLoaded) {
        
        ALog(@"track wasn't ready yet! %@", t);
        return;
        
    }

    
    NSMutableDictionary *value;
    value = [[NSMutableDictionary alloc] init];
    [value setObject:t.name forKey:@"name"];
    [value setObject:[[t.artists objectAtIndex:0] name] forKey:@"artist"];
    [value setObject:t.album.name forKey:@"album"];
    [value setObject:[t.album.spotifyURL absoluteString] forKey:@"albumURL"];
    [value setObject:[NSNumber numberWithInteger: t.discNumber] forKey:@"discNumber"];
    [value setObject:[NSNumber numberWithInteger: t.trackNumber] forKey:@"trackNumber"];
    [value setObject:t forKey:@"originalTrack"];
    
    [searchArrayController addObject:value];
    
    [value release];

}

- (void) emptySearchResults {
    [searchArrayController removeObjects: [searchArrayController arrangedObjects]];

}

- (void) populateSearchTable: (NSArray*) results {
    
    if (results == nil) {
        return;
    }
    [self emptySearchResults];
    for (id t in results) {
        if ([t isKindOfClass:[SPTrack class]]) {
            [self addTrackToSearchResults:t];
        } else if ([t isKindOfClass:[SPPlaylistItem class]]) {
            [self addTrackToSearchResults:[t item]];
        }

    }
    
    [searchResults reloadData];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	// Invoked when the current playback position changed (see below). This is a bit of a workaround
	// to make sure we don't update the position slider while the user is dragging it around. If the position
	// slider was read-only, we could just bind its value to playbackManager.trackPosition.
	
    if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
        if (![[self.playbackProgressSlider cell] isHighlighted]) {
			[self.playbackProgressSlider setDoubleValue:self.playbackManager.trackPosition];
		}
        
        // check if there's less than 5 percent left, then preload the next track.
        if (self.playbackManager.currentTrack.duration > 30.0 &&
            self.playbackManager.trackPosition / self.playbackManager.currentTrack.duration > 0.95) {
            if ([self.queueArrayController.content count] > 0) {
                
                id t = [self.queueArrayController.content objectAtIndex:0];
                t = [t objectForKey:@"originalTrack"];
                
                if (t != nil && [t isKindOfClass:[SPTrack class]]) {
                    
                    if (![(SPTrack*)(t) isLoaded]) {
                        DLog(@"try preloading next track... %@", t);
                        [[SPSession sharedSession] preloadTrackForPlayback:t
                                                                  callback:^(NSError *error) {
                                                                      DLog(@"preloaded %@:", t);
                                                                      if (error) {
                                                                          DLog(@"   preload error: %@", [error userInfo]);
                                                                      }
                                                                  }];
                        
                    }
                }
            }
        }
    } else if ([keyPath isEqualToString:@"search.tracks"]) {
        [self populateSearchTable:self.search.tracks];

    } else if([ keyPath isEqualToString:@"queueArrayController.arrangedObjects"]) {

        [self.nextButton setEnabled:([self.queueArrayController.arrangedObjects count] > 0)];
        
    } else if([keyPath isEqualToString:@"playbackManager.currentTrack"]) {
        
        DLog(@"playbackManager.currentTrack observed. value = %@", self.playbackManager.currentTrack);

        if (self.playbackManager.currentTrack == nil) {
            DLog(@"trying to advance to next track...");
            [self playNextTrack:nil];
        }
    }  else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)playNextTrack:(id)sender {
    // we seem to have stopped. grab next track off queue and continue.
    if ([self.queueArrayController.content count] > 0) {
        
        id t = [self.queueArrayController.content objectAtIndex:0];
        t = [t objectForKey:@"originalTrack"];

        if (t == nil) {
            DLog(@"hm, originalTrack of queue[0] == nil? not advancing track?");
            return;
        }
        
        // only Growl if auto-advanced (don't spam user after cmd-N)
        if (sender == nil) {
            [self doGrowlNotification:[t name] description:[t consolidatedArtists]];
        }
        
        if ([t availability] == SP_TRACK_AVAILABILITY_AVAILABLE) {
            [self playSPTrack:t];
            [self.queueArrayController removeObjectAtArrangedObjectIndex:0];
        } else {
            DLog(@"Track unavailable?? %@", t);
            // unavailable -> pause for now...
            [self.playbackManager setIsPlaying:NO];
        }

    } else {
        // the queue is empty, so we stop.
        DLog(@"empty queue => stop");
        [self scrobbleATrack:self.previousSong];
        self.previousSong = nil; // don't scrobble stuff twice.
    }
}

- (IBAction)quitFromLoginSheet:(id)sender {
	
	// Invoked by clicking the "Quit" button in the UI.
	
	[NSApp endSheet:self.loginSheet];
	[NSApp terminate:self];
}

- (IBAction)login:(id)sender {
	
	// Invoked by clicking the "Login" button in the UI.
	
	if ([[userNameField stringValue] length] > 0 &&
		[[passwordField stringValue] length] > 0) {
        
        [loginProgress startAnimation:self];
        [self.userNameField setEnabled:NO];
        [self.lfmUserNameField setEnabled:NO];
        [self.passwordField setEnabled:NO];
        [self.lfmPasswordField setEnabled:NO];
		
	   if ([savePassword state] == NSOnState) {
           [SSKeychain setPassword:[passwordField stringValue]
                        forService:kServiceName
                           account:[userNameField stringValue]];
           if ([[lfmPasswordField stringValue] length] > 0 &&
               [[lfmUserNameField stringValue] length] > 0) {
               
               [SSKeychain setPassword:[lfmPasswordField stringValue]
                            forService:kServiceNameLFM
                               account:[lfmUserNameField stringValue]];
           }
        }
        
        if ([[lfmPasswordField stringValue] length] > 0 &&
            [[lfmUserNameField stringValue] length] > 0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                DLog(@"trying to login to last.fm");
                BOOL retVal = [easyScrobble setUsername:[lfmUserNameField stringValue]
                                            andPassword:[lfmPasswordField stringValue]];
                DLog(@"last.fm logged in? %@", retVal?@"YES":@"NO");
                dispatch_sync(dispatch_get_main_queue(), ^{
       		  		if ( retVal == TRUE ) {
       		  			//Take action on success
                        DLog(@"last.fm logged in okay");
                        [[SPSession sharedSession] attemptLoginWithUserName:[userNameField stringValue]
                                                                   password:[passwordField stringValue]];
                        
       		  		}
       		  		if ( retVal == FALSE ) {
       		  			//Take action on failure
                        DLog(@"lastfm login problem");
                        [loginProgress stopAnimation:self];
                        
                        NSMutableDictionary *err = [NSMutableDictionary dictionary];

                        [err setValue:@"Failed to login to Last.fm" forKey:NSLocalizedDescriptionKey];
                        [NSApp presentError:[NSError errorWithDomain:@"Spotiqueue" code:0 userInfo:err]
                             modalForWindow:self.loginSheet
                                   delegate:nil
                         didPresentSelector:nil
                                contextInfo:nil];
                        [self.userNameField setEnabled:YES];
                        [self.lfmUserNameField setEnabled:YES];
                        [self.passwordField setEnabled:YES];
                        [self.lfmPasswordField setEnabled:YES];


       		  		}
                });
            });
        } else {
            // no last fm filled in, login directly.
            [[SPSession sharedSession] attemptLoginWithUserName:[userNameField stringValue]
                                                       password:[passwordField stringValue]];

        }
    
	} else {
		NSBeep();
	}
}

- (void) loveATrack:(SPTrack*)track {
    
    if (track == nil) {
        return;
    }
    
    if (!self.easyScrobble.isLoggedIn) {
        return;
    }
    
    dispatch_queue_t queue =
	dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        BOOL retVal = [easyScrobble loveTrack:track];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( retVal == TRUE ) {
                //Take action on success
                DLog(@"loved %@ successfully", track);
                [self doGrowlNotification:@"Loved!" description:[NSString
                                                                 stringWithFormat:@"%@ – %@",
                                                                 track.consolidatedArtists,
                                                                 track.name]];
            }
            if ( retVal == FALSE ) {
                //Take action on failure
                DLog(@"loving %@ failed", track);
            }
        });
    });
}



- (void) scrobbleATrack:(SPTrack*)track {
    
    DLog(@"entered scrobbleATrack: %@", track);
    
    if (track == nil) {
        DLog(@"bailing out on account of track being nil???");
        return;
    }
    
    if ([[[[NSUserDefaultsController sharedUserDefaultsController]
           values] valueForKey:@"pauseScrobbling"] intValue] == NSOnState) {
        DLog(@"do-not-scrobble cancelled scrobbling");
        return;
    }
    
    if (!self.easyScrobble.isLoggedIn || [self.easyScrobble.username isEqualToString:@""]) {
        DLog(@"not-logged-in, username = %@", self.easyScrobble.username);
        return;
    }
    
    DLog(@"hmm...");
    dispatch_queue_t queue =
	dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        DLog(@"trying to scrobble");
        BOOL retVal = [easyScrobble scrobbleTrack:track];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( retVal == TRUE ) {
                //Take action on success
                DLog(@"scrobbled %@ successfully", track);
            }
            if ( retVal == FALSE ) {
                //Take action on failure
                DLog(@"scrobbling %@ failed", track);
            }
        });
    });
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	
    // Invoked by SPSession after a successful login.
	
	[self.loginSheet orderOut:self];
    [loginProgress stopAnimation:self];
	[NSApp endSheet:self.loginSheet];
    
}

- (void)cancelLoadURLSheet:(id)sender{
    [self.loadPlaylistSheet orderOut:self];

	[NSApp endSheet:self.loadPlaylistSheet];

}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
    
	// Invoked by SPSession after a failed login.
    [loginProgress stopAnimation:self];

    [NSApp presentError:error
         modalForWindow:self.loginSheet
               delegate:nil
     didPresentSelector:nil
            contextInfo:nil];
    [self.userNameField setEnabled:YES];
    [self.lfmUserNameField setEnabled:YES];
    [self.passwordField setEnabled:YES];
    [self.lfmPasswordField setEnabled:YES];
}

-(void)sessionDidLogOut:(SPSession *)aSession; {}
-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
    
    [loginProgress stopAnimation:self];

	[[NSAlert alertWithMessageText:aMessage
					 defaultButton:@"OK"
				   alternateButton:@""
					   otherButton:@""
		 informativeTextWithFormat:@"This message was sent to you from the Spotify service."] runModal];
}

#pragma mark -
#pragma mark Playback

- (void) doGrowlNotification: (NSString*)title description: (NSString*) description {
    
    if (! [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"hideInfoPopups"]) {
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:description
                               notificationName:@"New track playing"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];

    }
   ;
    
    
  
}


- (void) playSPTrack:(SPTrack *)t {

    DLog(@"trying to play = %@", t);
    // the async doesn't seem to slow stuff down at all. 
    
    if(self.playbackManager.currentTrack == nil) // this means the track was finished.
        [self scrobbleATrack:self.previousSong];
    
    if (t == nil || ![t isKindOfClass:[SPTrack class]]) {
        
        DLog(@"danger will robinson!");
        return;
    }
    [self.playbackManager playTrack:t callback:^(NSError *error) {
        DLog(@"in callback of playSPTrack:");
        if (error) {
            [self.window presentError:error];
        } else {
            
            DLog(@"started playing %@", t);
        }
        
    } ];
    self.previousSong = t;


}

- (IBAction)seekToPosition:(id)sender {
	
	// Invoked by dragging the position slider in the UI.
	
	if (self.playbackManager.currentTrack != nil && self.playbackManager.isPlaying) {
		[self.playbackManager seekToTrackPosition:[sender doubleValue]];
	}
}


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "org.denknerd.Spotiqueue" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"org.denknerd.Spotiqueue"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Spotiqueue" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        DLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Spotiqueue.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        DLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)focusOnSearch:(id)sender {
    [self.searchField becomeFirstResponder];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    
    if ([SPSession sharedSession].connectionState != SP_CONNECTION_STATE_LOGGED_OUT &&
		[SPSession sharedSession].connectionState != SP_CONNECTION_STATE_UNDEFINED) {
        [[SPSession sharedSession] logout:^{
//		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:NO];
	}];
    }
	
    if ([self.loginSheet isVisible]) {
        [self.loginSheet orderOut:nil];
    }
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        DLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


- (NSString *)bundleVersionNumber {
    
    NSString* build = [[[NSBundle mainBundle] infoDictionary]
                       valueForKey:@"CFBundleVersion"];
    NSString* version = [[[NSBundle mainBundle] infoDictionary]
                         valueForKey:@"CFBundleShortVersionString"];
    
    return [NSString stringWithFormat:@"%@ (build %@)", version, build];
}
- (NSString*) copyrightLine {
    return [[[NSBundle mainBundle] infoDictionary]
            valueForKey:@"NSHumanReadableCopyright"];
}
@end
