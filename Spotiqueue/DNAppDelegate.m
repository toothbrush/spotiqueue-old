//
//  DNAppDelegate.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 22/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNAppDelegate.h"

@implementation DNAppDelegate

@synthesize persistentStoreCoordinator    = _persistentStoreCoordinator;
@synthesize managedObjectModel            = _managedObjectModel;
@synthesize managedObjectContext          = _managedObjectContext;

@synthesize playbackProgressSlider;
@synthesize searchResults;
@synthesize trackURLField;
@synthesize userNameField;
@synthesize passwordField;
@synthesize lfmPasswordField, lfmUserNameField;
@synthesize loginProgress;
@synthesize savePassword;
@synthesize loginSheet, searchField;
@synthesize window;
@synthesize playbackManager;
@synthesize search;
@synthesize queueTable;
@synthesize arrayController, queueArrayCtrl;



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
                
                while (![[[self.queueArrayCtrl.content objectAtIndex:0] objectForKey:@"originalTrack"] isEqual: played]) {
                    [self.queueArrayCtrl.content removeObjectAtIndex:0];
                }
                // finally remove the clicked track:
                [self.queueArrayCtrl.content removeObjectAtIndex:0];
                [self.queueTable deselectAll:nil];
                [self.queueTable reloadData];
            }
        } else if ([tracks count] > 1) {
            // the user pressed enter on a whole bunch of tracks.
            if ([self.queueArrayCtrl.content count] == 0) {
                // the queue is empty now, so we assume the user means to play the whole lot
                
                [self enqueueTracksBottom:tracks];
                
                if (playbackManager.currentTrack == nil) {
                    [self playNextTrack:nil];
                }

            }
        }
    }
}

- (void) enqueueTracksBottom:(NSArray *)tracks {
    
    NSMutableDictionary* value;
    for (SPTrack* t in tracks) {
        value = [NSMutableDictionary new];
        [value setObject:t.name forKey:@"name"];
        [value setObject:[[t.artists objectAtIndex:0] name] forKey:@"artist"];
        [value setObject:t.album.name forKey:@"album"];
        [value setObject:t forKey:@"originalTrack"];
        
        [queueArrayCtrl addObject:value];
    }
}

- (void) enqueueTracks:(NSArray *)tracks {
    
    NSMutableDictionary* value;
    NSEnumerator *enumerator = [tracks reverseObjectEnumerator];
    for (SPTrack* t in enumerator) {
        value = [NSMutableDictionary new];
        [value setObject:t.name forKey:@"name"];
        [value setObject:[[t.artists objectAtIndex:0] name] forKey:@"artist"];
        [value setObject:t.album.name forKey:@"album"];
        [value setObject:t forKey:@"originalTrack"];
        
        [queueArrayCtrl insertObject:value atArrangedObjectIndex:0];
    }

}

- (IBAction)searched:(id)sender{
    
    [self addObserver:self forKeyPath:@"search.tracks" options:0 context:nil];
    self.search = [SPSearch searchWithSearchQuery:[self.searchField stringValue] inSession:[SPSession sharedSession]];
    
    [self.searchResults setSortDescriptors: self.tracksSortDescriptors];
}



-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    
#include "SpotifySecrets.h"
    
	NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:sizeof(g_appkey)]
											   userAgent:@"com.spotify.SimplePlayer"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
    
	if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    
	[[SPSession sharedSession] setDelegate:self];
	self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    
	[self.window center];
	[self.window orderFront:nil];
   
    [self.searchResults setRelatedArrayController:self.arrayController];
    [self.queueTable setRelatedArrayController:self.queueArrayCtrl];
    [self.searchResults setTrackDelegate:self];
    [self.queueTable setTrackDelegate:self];
    
    
    NSArray *accounts = [SSKeychain accountsForService:kServiceName];
    NSArray *accountsLFM = [SSKeychain accountsForService:kServiceNameLFM];

    if (accounts != nil) {
        [passwordField setStringValue:[SSKeychain passwordForService:kServiceName account:[[accounts objectAtIndex:0] valueForKey:@"acct"]]];
        [userNameField setStringValue:[[accounts objectAtIndex:0] valueForKey:@"acct"]];
    }
    if (accountsLFM != nil) {
        [lfmPasswordField setStringValue:[SSKeychain passwordForService:kServiceNameLFM account:[[accountsLFM objectAtIndex:0] valueForKey:@"acct"]]];
        [lfmUserNameField setStringValue:[[accountsLFM objectAtIndex:0] valueForKey:@"acct"]];

    }
    
    

}

- (NSArray *)tracksSortDescriptors {
    return [NSArray arrayWithObjects:
            [NSSortDescriptor sortDescriptorWithKey:@"originalTrack.discNumber"
                                          ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"artist"
                                          ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"albumURL"
                                          ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"originalTrack.trackNumber"
                                          ascending:YES],
            nil];
}

- (IBAction)toggleFullScreen:(id)sender {
    [self.window toggleFullScreen:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	[self addObserver:self
		   forKeyPath:@"playbackManager.trackPosition"
			  options:0
			  context:nil];
    
    [self addObserver:self
		   forKeyPath:@"playbackManager.currentTrack"
			  options:0
			  context:nil];
	
	[NSApp beginSheet:self.loginSheet
	   modalForWindow:self.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
    
    [self.arrayController setDraggingEnabled:NO];
    easyScrobble = [LPEasyScrobble new];
    
    [self.searchResults setSortDescriptors: self.tracksSortDescriptors];
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	// Invoked when the current playback position changed (see below). This is a bit of a workaround
	// to make sure we don't update the position slider while the user is dragging it around. If the position
	// slider was read-only, we could just bind its value to playbackManager.trackPosition.
	
    if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
        if (![[self.playbackProgressSlider cell] isHighlighted]) {
			[self.playbackProgressSlider setDoubleValue:self.playbackManager.trackPosition];
		}
    } else if ([keyPath isEqualToString:@"search.tracks"]) {
//        NSLog(@"Search found tracks: %@", self.search.tracks);
        NSMutableDictionary *value;
        
        [[arrayController mutableArrayValueForKey:@"content"] removeAllObjects];
        
        for (SPTrack* t in self.search.tracks) {
            value = [NSMutableDictionary new];
            [value setObject:t.name forKey:@"name"];
            [value setObject:[[t.artists objectAtIndex:0] name] forKey:@"artist"];
            [value setObject:t.album.name forKey:@"album"];
            [value setObject:[t.album.spotifyURL absoluteString] forKey:@"albumURL"];
            [value setObject:t forKey:@"originalTrack"];
            
            [arrayController addObject:value];

        }

        [searchResults reloadData];

    }
    else if([keyPath isEqualToString:@"playbackManager.currentTrack"]) {
    

        if (self.playbackManager.currentTrack == nil) {
            [self playNextTrack:nil];
        }
    }
        else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)playNextTrack:(id)sender {
    // we seem to have stopped. grab next track off queue and continue.
    if ([self.queueArrayCtrl.content count] > 0) {
        
        id t = [self.queueArrayCtrl.content objectAtIndex:0];
        t = [t objectForKey:@"originalTrack"];
//        NSLog(@"next track should be %@" , t);
        [self.queueArrayCtrl removeObjectAtArrangedObjectIndex:0];
        [self playSPTrack:t];
    } else {
        // the queue is empty, so we stop.
        previousSong = nil; // don't scrobble stuff twice.
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
            [SSKeychain setPassword:[lfmPasswordField stringValue]
                         forService:kServiceNameLFM
                            account:[lfmUserNameField stringValue]];
        }
        
        if ([[lfmPasswordField stringValue] length] > 0 &&
            [[lfmUserNameField stringValue] length] > 0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                BOOL retVal = [easyScrobble setUsername:[lfmUserNameField stringValue]
                                            andPassword:[lfmPasswordField stringValue]];
                dispatch_sync(dispatch_get_main_queue(), ^{
       		  		if ( retVal == TRUE ) {
       		  			//Take action on success
                        NSLog(@"last.fm logged in okay");
                        [[SPSession sharedSession] attemptLoginWithUserName:[userNameField stringValue]
                                                                   password:[passwordField stringValue]];
                        
       		  		}
       		  		if ( retVal == FALSE ) {
       		  			//Take action on failure
                        NSLog(@"lastfm login problem");
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
        }
    
	} else {
		NSBeep();
	}
}

- (void) scrobbleATrack:(SPTrack*)track {
    
    if (track == nil) {
        return;
    }
    
    dispatch_queue_t queue =
	dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        BOOL retVal = [easyScrobble scrobbleTrack:track];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( retVal == TRUE ) {
                //Take action on success
                NSLog(@"scrobbled %@ successfully", track);
            }
            if ( retVal == FALSE ) {
                //Take action on failure
                NSLog(@"scrobbling failed");
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

- (void) playSPTrack:(SPTrack *)t {
    [SPAsyncLoading waitUntilLoaded:t timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
        
        if(self.playbackManager.currentTrack == nil) // this means the track was finished.
            [self scrobbleATrack:previousSong];
        
        [self.playbackManager playTrack:t callback:^(NSError *error) {
            if (error)
                [self.window presentError:error];
            
        }];
        previousSong = t;
    }];

}

- (IBAction)playTrack:(id)sender {
	
	// Invoked by clicking the "Play" button in the UI.
    
	if ([[trackURLField stringValue] length] > 0) {
		
		NSURL *trackURL = [NSURL URLWithString:[trackURLField stringValue]];
		[[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track) {
			if (track != nil) {
				
				[self playSPTrack:track];
			}
		}];
		return;
	}
	NSBeep();
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
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
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
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
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
//    [self removeObserver:self forKeyPath:@"search.tracks" context:nil];

    
    if ([SPSession sharedSession].connectionState != SP_CONNECTION_STATE_LOGGED_OUT &&
		[SPSession sharedSession].connectionState != SP_CONNECTION_STATE_UNDEFINED) {
        [[SPSession sharedSession] logout:^{
//		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:NO];
	}];
    }
	

    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
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
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
