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
SPSessionDelegate, DNTrackTableDelegate, NSTableViewDelegate> {

@private
//	NSWindow *__unsafe_unretained window;
	NSPanel *__unsafe_unretained loginSheet;
	NSTextField * __unsafe_unretained userNameField;
	NSSecureTextField *__unsafe_unretained passwordField;
//	NSTimeInterval currentTrackPosition;
    
    LPEasyScrobble * easyScrobble;
	SPTrack* previousSong;
	SPPlaybackManager *playbackManager;

	NSSlider *__unsafe_unretained playbackProgressSlider;
}

@property (nonatomic, retain) IBOutlet NSButton * nextButton;
@property (assign) IBOutlet NSSlider *playbackProgressSlider;
@property (nonatomic, retain) IBOutlet NSButton* scrobbleEnabled;

@property (assign)   IBOutlet DNTrackTable *searchResults;
@property (assign)   IBOutlet DNTrackTable *queueTable;
@property (strong) IBOutlet RSRTVArrayController *arrayController;
@property (strong) IBOutlet RSRTVArrayController *queueArrayCtrl;
@property (nonatomic, retain) IBOutlet NSTextField* trackDurationLabel;



@property (readonly) IBOutlet NSString* trackDuration;

@property (assign) IBOutlet NSTextField *userNameField;
@property (assign) IBOutlet NSTextField *lfmUserNameField;
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSProgressIndicator *loginProgress;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* searchIndicator;
@property (assign) IBOutlet NSButton *savePassword;
@property (assign) IBOutlet NSSecureTextField *passwordField;
@property (assign) IBOutlet NSSecureTextField *lfmPasswordField;
@property (unsafe_unretained) IBOutlet NSPanel *loginSheet;
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain)     SPSearch * search;


- (IBAction)login:(id)sender;

- (IBAction)searched:(id)sender;
- (IBAction)playOrPause:(id)sender;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

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