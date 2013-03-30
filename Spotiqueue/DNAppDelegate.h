//
//  DNAppDelegate.h
//  Spotiqueue
//
//  Created by Paul van der Walt on 22/12/2012.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DNTrackTableDelegate.h"
#import "SSKeychain.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "DNTrackTable.h"
#import "LPEasyScrobble.h"
#import "RSRTVArrayController.h"

@interface DNAppDelegate : NSObject <NSApplicationDelegate,
SPSessionDelegate, DNTrackTableDelegate, NSTableViewDelegate,
SPPlaylistDelegate> {

@private

	NSTextField * __unsafe_unretained userNameField;
	NSSecureTextField *__unsafe_unretained passwordField;
    
	SPPlaybackManager *playbackManager;

	NSSlider *__unsafe_unretained playbackProgressSlider;
}

@property (nonatomic, retain) LPEasyScrobble * easyScrobble;
@property (nonatomic, retain)	SPTrack* previousSong;

@property (nonatomic, retain) IBOutlet NSButton * nextButton;
@property (assign) IBOutlet NSSlider *playbackProgressSlider;

@property (assign)   IBOutlet DNTrackTable *searchResults;
@property (assign)   IBOutlet DNTrackTable *queueTable;
@property (strong) IBOutlet RSRTVArrayController *searchArrayController;
@property (strong) IBOutlet RSRTVArrayController *queueArrayController;




@property (readonly) IBOutlet NSString* trackDuration;

@property (assign) IBOutlet NSTextField *userNameField;
@property (assign) IBOutlet NSTextField *lfmUserNameField;
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSProgressIndicator *loginProgress;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* searchIndicator;
@property (assign) IBOutlet NSButton *savePassword;
@property (assign) IBOutlet NSSecureTextField *passwordField;
@property (assign) IBOutlet NSSecureTextField *lfmPasswordField;
@property (nonatomic, retain) IBOutlet NSPanel *loginSheet;
@property (nonatomic, retain) IBOutlet NSPanel *loadPlaylistSheet;
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain)     SPSearch * search;


- (IBAction)login:(id)sender;

- (IBAction)searched:(id)sender;
- (IBAction)playOrPause:(id)sender;

- (IBAction)loadPlaylistFromURL:(id)sender;
- (IBAction)showLoadPlaylist:(id)sender;
- (IBAction)loadStarredTracks:(id)sender;
- (IBAction)cancelLoadURLSheet:(id)sender;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, retain) IBOutlet NSPopUpButton* playlistSelectionMenu;



- (IBAction)saveAction:(id)sender;

- (NSArray *)tracksSortDescriptors;
- (IBAction)quitFromLoginSheet:(id)sender;

#pragma mark -

@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;


- (IBAction)seekToPosition:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;

- (IBAction)focusOnSearch:(id)sender;
- (IBAction)playNextTrack:(id)sender;

- (void) playSPTrack:(SPTrack*) t;

@end