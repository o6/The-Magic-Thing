//
//  ConversionController.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/6/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import "ConversionController.h"
#define ffmpeg [[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:@"ffmpeg"]
#define ffmpeg2theora [[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:@"ffmpeg2theora"]

static ConversionController *globalConversionController;
@implementation ConversionController
//@synthesize fileName;
@synthesize betaLog;
- (id)init {
	if (self = [super init])
	{
		if (!globalConversionController)
			globalConversionController = [self retain];
	}
	return self;
}
+ (id)controller {
	id theController = globalConversionController;
	if (!theController)
		theController = [[[self alloc] init] autorelease];
	return theController;
}
- (IBAction)logFileName:(id)sender {
	NSLog(@"fileName = %@, in %@", [self fileName], self);
}
//Custom Getters/Setters for fileName
- (NSString *)fileName {
	return fileName;
}
- (void)setFileName:(NSString *)file {
	fileName = [file copy];
}
- (IBAction)convert:(id)sender {
	int result;
	NSOpenPanel *addpanel = [NSOpenPanel openPanel];
	[addpanel setCanChooseFiles:NO];
	[addpanel setCanChooseDirectories:YES];
	[addpanel setAllowsMultipleSelection:NO];
	[addpanel setTitle:@"Select the location to save videos in."];
	result = [addpanel runModalForDirectory:nil file:nil types:nil];
	if(result == NSCancelButton) {
		return;
	}
	outputDirectory = [[[addpanel filenames] objectAtIndex:0] copy];
	int appendedNumber = 1;
	theoraOutputFileName = [[outputDirectory stringByAppendingPathComponent:[[NSFileManager defaultManager] displayNameAtPath:fileName]] stringByDeletingPathExtension];
	while ([[NSFileManager defaultManager] fileExistsAtPath:[theoraOutputFileName stringByAppendingString:@" (Ogg).ogv"]]) {
		theoraOutputFileName = [theoraOutputFileName stringByAppendingString:[NSString stringWithFormat:@" %d", appendedNumber]];
		appendedNumber = appendedNumber + 1;
	}
	theoraOutputFileName = [theoraOutputFileName stringByAppendingString:@" (Ogg).ogv"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theoraUpdated:) name:NSFileHandleReadCompletionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theoraUpdated:) name:NSFileHandleDataAvailableNotification object:nil];
	NSString *qual = [quality stringValue];
	NSLog(@"Quality level selected by user: %@", qual);
	NSTask *theoraTask = [[NSTask alloc] init];
	NSPipe *theoraPipe = [NSPipe pipe];
	theoraHandle = [theoraPipe fileHandleForReading];
	[theoraTask setLaunchPath:ffmpeg2theora];
	NSLog(@"Planned location for Ogg file: %@", [NSString stringWithFormat:@"\"%@\"", [NSString stringWithUTF8String:[theoraOutputFileName fileSystemRepresentation]]]);
	[theoraTask setArguments:[NSArray arrayWithObjects: @"-v", qual, @"-a", qual, [self fileName], @"-o", theoraOutputFileName , nil]];
	[theoraTask setStandardOutput:theoraPipe];
	[theoraTask setStandardError:theoraPipe];
	[[QuitController controller] addProcess:@"ffmpeg2theora"];
	[theoraTask launch];
	[theoraHandle readInBackgroundAndNotify];
	//[NSTask launchedTaskWithLaunchPath:ffmpeg arguments:[NSArray arrayWithObjects:@"-y", @"-i", [self fileName], @"-an", @"-v", @"1", @"-threads", @"auto", @"-vcodec", @"h264", @"-b", @"500", @"-bt", @"175", @"-refs", @"1", @"-loop", @"1", @"-deblockalpha", @"0", @"-deblockbeta", @"0", @"-parti4x4", @"1", @"-partp8x8", @"1", @"-me", @"full", @"-subq", @"1", @"-me_range", @"21", @"-chroma", @"1", @"-slice", @"2", @"-max_b_frames", @"0", @"-level", @"30", @"-g", @"300", @"-keyint_min", @"30", @"-sc_threshold", @"40", @"-rc_eq", @"'blurCplx^(1-qComp)'", @"-qcomp", @"0.7", @"-qmax", qual, @"-max_qdiff", @"4", @"-i_quant_factor", @"0.71428572", @"-rc_max_rate", @"768", @"-rc_buffer_size", @"244", @"-cmp", @"1", @"-s", @"640x480", @"-f", @"mp4", @"-pass", @"1", @"/Users/carterallen/Desktop/h264.mov", nil]];
}
- (void)theoraUpdated:(NSNotification *)aNotification {
	[convertButton setHidden:YES];
	[qualityLabel setHidden:YES];
	[quality setHidden:YES];
	[estimateLabel setHidden:NO];
	[progBar setHidden:NO];
	[progBar2 setHidden:NO];
	[progBar setUsesThreadedAnimation:YES];
	[progBar2 setUsesThreadedAnimation:YES];
	responseString = [[[NSString alloc] initWithData:[[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding: NSUTF8StringEncoding] autorelease];
	//NSLog(@"Received response (type: %@, array count: %d) from ffmpeg2theora process: %@", [aNotification name], [[responseString componentsSeparatedByString:@" "] count], responseString);
	if ([responseString rangeOfString:@"time remaining"].location != NSNotFound) {
		NSArray *responseArray = [responseString componentsSeparatedByString:@" "];
		if ([responseArray count] == 20) {
			NSString *currentTime = [responseArray objectAtIndex:13];
			NSArray *timeArray = [currentTime componentsSeparatedByString:@":"];
			NSString *currentSeconds = [timeArray objectAtIndex:2];
			NSString *currentMinutes = [timeArray objectAtIndex:1];
			NSString *currentHours = [timeArray objectAtIndex:0];
			secondsRemaining = ([currentHours intValue] * 3600) + ([currentMinutes intValue] * 60) + [currentSeconds intValue];
			if ([[aNotification name]isEqualToString:NSFileHandleReadCompletionNotification]) {
				if (secondsRemaining == 0) {
					if (!theoraEnded)
						theoraEnded = YES;
					else
						return;
					if (progTimer != nil) {
						[progBar setDoubleValue:(double)([progBar maxValue]/2)];
						[[QuitController controller] removeProcess:@"ffmpeg2theora"];
						[progTimer invalidate];
						progTimer = nil;
						[estimateLabel setStringValue:@"(Ogg) Encode complete"];
						[[NSNotificationCenter defaultCenter] removeObserver:self];
						[self convertH264];
						return;
					}
				}
			}
			[self startTimer];
		}
	}
	[theoraHandle readInBackgroundAndNotify];
	return;
	
}
- (void)updateProgressBar:(NSTimer *)sender {
	if (theoraEnded) 
		return;
	secondsElapsed++;
	[progBar setIndeterminate:NO];
	if (((double)secondsElapsed/2.0 / (double)(secondsElapsed + secondsRemaining)) > ([progBar doubleValue] / [progBar maxValue])) {
		[progBar setDoubleValue:secondsElapsed/2.0];
		[progBar setMaxValue:secondsElapsed + secondsRemaining];
		[estimateLabel setStringValue:[NSString stringWithFormat:@"(1/2) Encoding video to Ogg Theora... %.0f%% complete", ((double)secondsElapsed / (double)(secondsElapsed + secondsRemaining)) * 100]];
		[[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%.0f%%", (((double)secondsElapsed / (double)(secondsElapsed + secondsRemaining)) * 100)/2]];
		[progBar setNeedsDisplay:YES];
	}	
}
- (void)startTimer {
	if (theoraEnded)
		return;
	if (progTimer != nil) {
		if ([progTimer isValid]) {
			return;
		}
	}
	progTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
}
- (void)convertH264 {
	[estimateLabel setStringValue:@"(h.264) Preparing..."];
	NSString *command = [NSString stringWithFormat:@"\"%@\" -i \"%@\" 2>&1 | grep \"Duration\" | cut -d ' ' -f 4 | sed s/,// > /tmp/TMTinfo.txt", [NSString stringWithUTF8String:[ffmpeg fileSystemRepresentation]], [NSString stringWithUTF8String:[fileName fileSystemRepresentation]]];
	system([command UTF8String]);
	NSLog(@"Description of source video, generated by ffmpeg: %@", [NSString stringWithContentsOfFile:@"/tmp/TMTinfo.txt" encoding:NSUTF8StringEncoding error:nil]);
	[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/TMTinfo.txt" error:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(h264Updated:) name:NSFileHandleReadCompletionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(h264Updated:) name:NSFileHandleDataAvailableNotification object:nil];
	[progBar setMaxValue:(double)100];
	[progBar setDoubleValue:(double)50];
	[progBar setUsesThreadedAnimation:YES];
	[self startH264Encode];
}
- (void)h264Updated:(NSNotification *)aNotification {
	responseString = [[[NSString alloc] initWithData:[[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding: NSUTF8StringEncoding] autorelease];
	//NSLog(@"Received response (type: %@, array count: %d) from ffmpeg process: %@", [aNotification name], [[responseString componentsSeparatedByString:@" "] count], responseString);
	if ([responseString rangeOfString:@"final"].location != NSNotFound) {
		[[QuitController controller] removeProcess:@"ffmpeg"];
		[self showCompletionScreen];
		return;
	}
	if ([responseString rangeOfString:@"time="].location != NSNotFound) {
		NSArray *responseArray = [responseString componentsSeparatedByString:@" "];
		float elapsedTime;
		if ([responseArray count] == 16) {
			elapsedTime = [self elapsedTimeForResponseString:responseString];
		}
		else if ([responseArray count] == 14) {
			NSString *currentTime = [[responseString componentsSeparatedByString:@" "] objectAtIndex:8];
			NSArray *timeArray = [currentTime componentsSeparatedByString:@"="];
			NSString *currentSeconds = [timeArray objectAtIndex:1];
			elapsedTime = [currentSeconds floatValue];
		}
		else {
			[h264Handle readInBackgroundAndNotify];
			return;
		}
		float percent = (elapsedTime / videoDuration) * 100;
		[estimateLabel setStringValue:[NSString stringWithFormat:@"(2/2) Encoding video to h.264... %.0f%% complete", percent]];
		[[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%.0f%%", (double)(percent/2.0)+50]];
		//NSLog(@"Current status of h264 process, according to TMT: %.0f percent complete", percent);
		float newProgValue = (percent / 2) + 50;
		if (newProgValue >= 100) {
			[[QuitController controller] removeProcess:@"ffmpeg"];
			[self showCompletionScreen];
			return;
		}
		if ((double)newProgValue > [progBar doubleValue])
			[progBar setDoubleValue:(double)newProgValue];
	}
	[h264Handle readInBackgroundAndNotify];
}
- (float)durationForVideo:(NSString *)videoPath {
	NSString *command = [NSString stringWithFormat:@"\"%@\" -i \"%@\" 2>&1 | grep \"Duration\" | cut -d ' ' -f 4 | sed s/,// > /tmp/TMTinfo.txt", [NSString stringWithUTF8String:[ffmpeg fileSystemRepresentation]], [NSString stringWithUTF8String:[videoPath fileSystemRepresentation]]];
	system([command UTF8String]);
	NSArray *clockArray = [[NSString stringWithContentsOfFile:@"/tmp/TMTinfo.txt" encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@":"];
	[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/TMTinfo.txt" error:nil];
	return ([[clockArray objectAtIndex:0] floatValue] * 3600) + ([[clockArray objectAtIndex:1] floatValue] * 60) + [[clockArray objectAtIndex:2] floatValue];
}
- (float)elapsedTimeForResponseString:(NSString *)response {
	NSString *currentTime = [[response componentsSeparatedByString:@" "] objectAtIndex:10];
	NSArray *timeArray = [currentTime componentsSeparatedByString:@"="];
	NSString *currentSeconds = [timeArray objectAtIndex:1];
	return [currentSeconds floatValue];
}
- (void)startH264Encode {
	int appendedNumber = 1;
	videoDuration = [self durationForVideo:[self fileName]];
	h264OutputFileName = [[outputDirectory stringByAppendingPathComponent:[[NSFileManager defaultManager] displayNameAtPath:fileName]] stringByDeletingPathExtension];
	while ([[NSFileManager defaultManager] fileExistsAtPath:[h264OutputFileName stringByAppendingString:@" (h264).mov"]]) {
		h264OutputFileName = [h264OutputFileName stringByAppendingString:[NSString stringWithFormat:@" %d", appendedNumber]];
		appendedNumber = appendedNumber + 1;
	}
	h264OutputFileName = [h264OutputFileName stringByAppendingString:@" (h264).mov"];
	NSLog(@"Planned output filename for h264 file: %@", h264OutputFileName);
	NSLog(@"Quality slider float value = %f", [quality floatValue]);
	NSString *qual = [NSString stringWithFormat:@"%f", (((10.00 - ([quality floatValue] - 1.00)) * 10) / 2)];
	NSLog(@"h.264 quality = %@", qual);
	NSTask *h264Task = [[NSTask alloc] init];
	NSPipe *h264Pipe = [NSPipe pipe];
	h264Handle = [h264Pipe fileHandleForReading];
	[h264Task setLaunchPath:ffmpeg];
	//[h264Task setArguments:[NSArray arrayWithObjects:@"-y", @"-i", [self fileName], @"-v", @"1", @"-threads", @"auto", @"-vcodec", @"h264", @"-b", @"500", @"-bt", @"175", @"-refs", @"1", @"-loop", @"1", @"-deblockalpha", @"0", @"-deblockbeta", @"0", @"-parti4x4", @"1", @"-partp8x8", @"1", @"-me", @"full", @"-subq", @"1", @"-me_range", @"21", @"-chroma", @"1", @"-slice", @"2", @"-max_b_frames", @"0", @"-level", @"30", @"-g", @"300", @"-keyint_min", @"30", @"-sc_threshold", @"40", @"-qcomp", @"0.7", @"-qmax", qual, @"-max_qdiff", @"4", @"-i_quant_factor", @"0.71428572", @"-rc_max_rate", @"768", @"-rc_buffer_size", @"244", @"-cmp", @"1", @"-s", @"640x480", @"-f", @"mp4", @"-pass", @"1", h264OutputFileName, nil]];
	[h264Task setArguments:[NSArray arrayWithObjects:@"-y", @"-i", [self fileName], @"-v", @"1", @"-vcodec", @"h264", /*@"-b", @"500", @"-bt", @"175",*/ @"-qmax", qual, @"-max_qdiff", @"4", @"-f", @"mp4", h264OutputFileName, nil]];
	[h264Task setStandardOutput:h264Pipe];
	[h264Task setStandardError:h264Pipe];
	[[QuitController controller] addProcess:@"ffmpeg"];
	[h264Task launch];
	[h264Handle readInBackgroundAndNotify];
}
- (void)showCompletionScreen {
	[NSApp requestUserAttention:NSInformationalRequest];
	[[NSApp dockTile] setBadgeLabel:@""];
	[theoraIcon setTarget:self];
	[h264Icon setTarget:self];
	[theoraIcon setAction:@selector(mouseDown:)];
	[h264Icon setAction:@selector(mouseDown:)];
	
	[theoraIcon setRepresentedFile:theoraOutputFileName];
	[h264Icon setRepresentedFile:h264OutputFileName];
	
	[tabView setTransitionStyle:AnimatingTabViewSwipeTransitionStyle];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:2]];
}
- (IBAction)copyHTML:(id)sender {
	
}
- (IBAction)startOver:(id)sender {
	[tabView setTransitionStyle:AnimatingTabViewSwipeTransitionStyle];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];
}
- (IBAction)showTheoraInFinder:(id)sender {
	
}
- (IBAction)showH264InFinder:(id)sender {
	
}
- (void)resetUI {
	[fileName copy];
	[progBar setMaxValue:(double)1];
	[progBar setDoubleValue:(double)0];
	[progBar setHidden:YES];
	[convertButton setHidden:NO];
	[qualityLabel setHidden:NO];
	[estimateLabel setHidden:YES];
	[quality setHidden:NO];
}
@end
