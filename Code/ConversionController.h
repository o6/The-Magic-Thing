//
//  ConversionController.h
//  The Magic Thing
//
//  Created by Carter Allen on 8/6/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QuitController.h"
#import "AnimatingTabView.h"
#import "IconFamily.h"
#import "IconImageView.h"

@interface ConversionController : NSObject {
	BOOL betaLog;
	
	NSString *theoraOutputFileName;
	NSString *h264OutputFileName;
	NSString *outputDirectory;
	NSString *fileName;
	NSString *responseString;
	NSFileHandle *theoraHandle;
	NSFileHandle *h264Handle;
	NSString *duration;
	NSTimer *progTimer;
	NSTimer *progTimer2;
	int secondsRemaining;
	int secondsElapsed;
	float videoDuration;
	BOOL theoraEnded;
	IBOutlet NSSlider *quality;
	IBOutlet NSProgressIndicator *progBar;
	IBOutlet NSProgressIndicator *progBar2;
	IBOutlet NSButton *convertButton;
	IBOutlet NSTextField *qualityLabel;
	IBOutlet NSTextField *estimateLabel;
	IBOutlet AnimatingTabView *tabView;
	
	IBOutlet IconImageView *theoraIcon;
	IBOutlet IconImageView *h264Icon;
}
+ (id)controller;
- (IBAction)convert:(id)sender;
- (void)theoraUpdated:(NSNotification *)aNotification;
- (void)updateProgressBar:(NSTimer *)sender;
- (void)startTimer;
- (void)convertH264;
- (void)h264Updated:(NSNotification *)aNotification;
- (float)durationForVideo:(NSString *)videoPath;
- (float)elapsedTimeForResponseString:(NSString *)response;
- (void)startH264Encode;
- (void)showCompletionScreen;
- (IBAction)copyHTML:(id)sender;
- (IBAction)startOver:(id)sender;
- (IBAction)showTheoraInFinder:(id)sender;
- (IBAction)showH264InFinder:(id)sender;
- (void)resetUI;
- (IBAction)logFileName:(id)sender;

//Custom Getters/Setters for fileName
- (NSString *)fileName;
- (void)setFileName:(NSString *)file;
//@property (copy) NSString* fileName;
@property (assign) BOOL betaLog;
@end
