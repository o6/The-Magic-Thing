//
//  QuitController.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/7/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import "QuitController.h"

static QuitController *globalQuitController;
@implementation QuitController
- (void)awakeFromNib {
	processes = [[NSMutableArray alloc] init];
}
- (id)init
{
	if (self = [super init])
	{
		if (!globalQuitController)
			globalQuitController = [self retain];
	}
	return self;
}
+ (id)controller
{
	id theController = globalQuitController;
	if (!theController)
		theController = [[[self alloc] init] autorelease];
	return theController;
}
- (void)addProcess:(NSString *)process {
	if (![processes containsObject:process]) {
		[processes addObject:process];
	}
}
- (void)removeProcess:(NSString *)process {
	if ([processes containsObject:process]) {
		[processes removeObject:process];
	}
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if ([[ConversionController controller] betaLog]) {
		NSRunAlertPanel(@"Beta Logging Enabled", @"Important debugging information will be logged to a text file on your desktop.", @"OK", nil, nil);
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
		NSString *desktopDirectory = [paths objectAtIndex:0];
		NSString *logPath = [desktopDirectory stringByAppendingPathComponent:@"TMT.log"];
		freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	}
	else {
		NSString *logPath = @"/dev/null";
		freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	}
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if ([processes count] != 0) {
		int decision = NSRunAlertPanel(@"Are you sure you want to quit?", @"If you interrupt conversion now by quitting, the output video may not be usable.", @"Cancel", @"Quit", nil);
		if (decision == NSAlertDefaultReturn)
			return NSTerminateCancel;
		else {
			if ([processes containsObject:@"ffmpeg"])
			system("killall ffmpeg");
			else
			system("killall ffmpeg2theora");
			return NSTerminateNow;
		}
	}
	return NSTerminateNow;
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
	[dView openFile:filename];
	return YES;
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}
@end
