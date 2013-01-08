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

#import "RSRTVArrayController.h"

@interface DNAppDelegate : NSObject <NSApplicationDelegate,
SPSessionDelegate, DNTrackTableDelegate, NSTableViewDelegate> {

@private
	NSWindow *__unsafe_unretained window;
	NSPanel *__unsafe_unretained loginSheet;
	NSTextField *__weak userNameField;
	NSSecureTextField *__weak passwordField;
	NSTimeInterval currentTrackPosition;
	
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
//@property (strong) IBOutlet NSArrayController *arrayController;
//@property (strong) IBOutlet NSArrayController *queueArrayCtrl;



@property (weak) IBOutlet NSTextField *userNameField;
@property (weak) IBOutlet NSProgressIndicator *loginProgress;
@property (weak) IBOutlet NSButton *savePassword;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (unsafe_unretained) IBOutlet NSPanel *loginSheet;
@property (assign) IBOutlet NSWindow *window;
@property (strong)     SPSearch * search;


- (IBAction)login:(id)sender;

- (IBAction)searched:(id)sender;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;


- (IBAction)quitFromLoginSheet:(id)sender;

#pragma mark -

@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;

- (IBAction)playTrack:(id)sender;
- (IBAction)seekToPosition:(id)sender;
- (IBAction)playNextTrack:(id)sender;

- (void) playSPTrack:(SPTrack*) t;

@end





const uint8_t g_appkey[] = {
	0x01, 0x64, 0x97, 0x8D, 0x8A, 0x7C, 0xAB, 0x3D, 0x46, 0xB7, 0xBA, 0xD1, 0xAC, 0x4E, 0x76, 0x8F,
	0xBD, 0xB9, 0x35, 0x2F, 0x39, 0x86, 0x7B, 0x03, 0xC1, 0xBA, 0xA1, 0x26, 0xCD, 0x2B, 0x56, 0x39,
	0x8C, 0x7F, 0xF2, 0x66, 0xA6, 0xA3, 0xA6, 0x13, 0xCF, 0x84, 0x1C, 0x74, 0x1B, 0xD2, 0xCF, 0x8C,
	0xB4, 0x78, 0x20, 0xA1, 0x87, 0xEE, 0xD6, 0x48, 0xC5, 0xE9, 0x7C, 0x64, 0x4A, 0x36, 0x49, 0xD5,
	0xA3, 0xD9, 0xCA, 0xF2, 0xE6, 0xCA, 0xDA, 0xA8, 0x12, 0x35, 0x92, 0x95, 0x94, 0x51, 0x2B, 0x45,
	0x97, 0x73, 0xDE, 0xA4, 0xAC, 0x83, 0x80, 0x76, 0x98, 0x5B, 0xB6, 0xDE, 0x4F, 0x6E, 0x6D, 0x58,
	0xE3, 0xF0, 0xE5, 0x68, 0x4B, 0x53, 0x4F, 0xE5, 0x0A, 0x4D, 0x92, 0x1C, 0x6C, 0xEE, 0x70, 0xD4,
	0xAD, 0xF5, 0x3D, 0xC5, 0xED, 0xD3, 0x1A, 0xF2, 0x27, 0x94, 0xE2, 0x47, 0xED, 0xEE, 0xE6, 0x53,
	0xD3, 0x87, 0x94, 0x10, 0xCB, 0x98, 0x78, 0x2B, 0x35, 0x3D, 0xB4, 0x4A, 0x5F, 0x8B, 0x2F, 0x89,
	0xEA, 0xF5, 0x7A, 0x7C, 0x26, 0x4C, 0x07, 0x41, 0x17, 0x59, 0xE0, 0x2B, 0x23, 0xF1, 0xE4, 0xDC,
	0x5B, 0x95, 0x67, 0x7E, 0x66, 0xF9, 0xDB, 0xD7, 0x13, 0x73, 0x8A, 0xCA, 0xC5, 0x13, 0x51, 0xDC,
	0xC0, 0x8C, 0x81, 0x9D, 0xBB, 0x97, 0x36, 0xB6, 0x43, 0x7B, 0xB3, 0x63, 0xE5, 0x94, 0x32, 0xEF,
	0x3E, 0x34, 0x60, 0x57, 0xFD, 0xEB, 0x6B, 0x6B, 0x0A, 0x96, 0x9E, 0x67, 0xA4, 0xE2, 0xE6, 0x8A,
	0x97, 0x55, 0xB4, 0xDE, 0x12, 0x9E, 0xB1, 0x9E, 0x1C, 0xF2, 0xA4, 0x29, 0x5E, 0xAD, 0x74, 0x3F,
	0xF0, 0xC5, 0x6C, 0x45, 0xD0, 0x9A, 0x58, 0x22, 0x97, 0xD5, 0x55, 0x89, 0x98, 0x9C, 0xF8, 0x04,
	0x3B, 0xFE, 0xA4, 0x55, 0x9D, 0x9D, 0x23, 0xDE, 0x01, 0x25, 0xAB, 0xF6, 0x07, 0x69, 0x4C, 0x10,
	0x3B, 0xB7, 0xE6, 0xC2, 0xFD, 0x52, 0xC2, 0x6F, 0x34, 0xD7, 0x4D, 0x4B, 0x9B, 0x7F, 0x7A, 0x0B,
	0x7B, 0x8C, 0xF8, 0x73, 0xD4, 0x01, 0x63, 0xA5, 0xB9, 0x39, 0x8F, 0x44, 0x96, 0xE4, 0xCA, 0xCF,
	0x91, 0x3F, 0xDA, 0x11, 0x6D, 0x42, 0x46, 0x6B, 0x5C, 0x80, 0xF3, 0xD9, 0x15, 0xB1, 0x63, 0x09,
	0x77, 0x61, 0xAA, 0x8A, 0x7F, 0x10, 0xB1, 0x65, 0x51, 0xEB, 0xAF, 0xD6, 0xC7, 0x66, 0xBC, 0xB4,
	0x56,
};
