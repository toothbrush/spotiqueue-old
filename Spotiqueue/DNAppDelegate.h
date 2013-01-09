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
	NSWindow *__unsafe_unretained window;
	NSPanel *__unsafe_unretained loginSheet;
	NSTextField *__weak userNameField;
	NSSecureTextField *__weak passwordField;
	NSTimeInterval currentTrackPosition;
    
    LPEasyScrobble * easyScrobble;
	SPTrack* previousSong;
	SPPlaybackManager *playbackManager;

	NSTextField *__weak trackURLField;
	NSSlider *__weak playbackProgressSlider;
}

@property (weak) IBOutlet NSSlider *playbackProgressSlider;
@property (weak) IBOutlet NSTextField *trackURLField;


@property (weak)   IBOutlet DNTrackTable *searchResults;
@property (weak)   IBOutlet DNTrackTable *queueTable;
@property (strong) IBOutlet RSRTVArrayController *arrayController;
@property (strong) IBOutlet RSRTVArrayController *queueArrayCtrl;






@property (weak) IBOutlet NSTextField *userNameField;
@property (weak) IBOutlet NSTextField *lfmUserNameField;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *loginProgress;
@property (weak) IBOutlet NSButton *savePassword;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (weak) IBOutlet NSSecureTextField *lfmPasswordField;
@property (unsafe_unretained) IBOutlet NSPanel *loginSheet;
@property (assign) IBOutlet NSWindow *window;
@property (strong)     SPSearch * search;


- (IBAction)login:(id)sender;

- (IBAction)searched:(id)sender;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (NSArray *)tracksSortDescriptors;
- (IBAction)quitFromLoginSheet:(id)sender;

#pragma mark -

@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;

- (IBAction)playTrack:(id)sender;
- (IBAction)seekToPosition:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)focusOnSearch:(id)sender;
- (IBAction)playNextTrack:(id)sender;

- (void) playSPTrack:(SPTrack*) t;

@end