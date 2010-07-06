//
//  WindowDelegate.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/15/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import "WindowDelegate.h"

static WindowDelegate *globalWindowController;
@implementation WindowDelegate
- (id)init
{
	if (self = [super init])
	{
		if (!globalWindowController)
			globalWindowController = [self retain];
	}
	return self;
}
+ (id)sharedInstance
{
	id theController = globalWindowController;
	if (!theController)
		theController = [[[self alloc] init] autorelease];
	return theController;
}
- (void)awakeFromNib {
	controlTopColor = [NSArray arrayWithObjects:[controlTop fillStartingColor], [controlTop fillEndingColor], nil];
	controlBottomColor = [NSArray arrayWithObjects:[controlBottom fillStartingColor], [controlBottom fillEndingColor], nil];
	completeTopColor = [NSArray arrayWithObjects:[completeTop fillStartingColor], [completeTop fillEndingColor], nil];
	completeBottomColor = [NSArray arrayWithObjects:[completeBottom fillStartingColor], [completeBottom fillEndingColor], nil];
	[controlTitleField setSolidColor:[NSColor blackColor]];
	[completeTitleField setSolidColor:[NSColor blackColor]];
	[qualityLabel setTextColor:[NSColor blackColor]];
}
- (void)setDisplayedState:(int)state {
	if (state == 0)
		[self windowDidResignKey:nil];
	else
		[self windowDidBecomeKey:nil];
}
- (void)windowDidResignKey:(NSNotification *)notification {
	[controlTop setFillStartingColor:[[controlTop fillStartingColor] highlightWithLevel:0.4]];
	[controlTop setFillEndingColor:[[controlTop fillEndingColor] highlightWithLevel:0.4]];
	[controlBottom setFillStartingColor:[[controlBottom fillStartingColor] highlightWithLevel:0.4]];
	[controlBottom setFillEndingColor:[[controlBottom fillEndingColor] highlightWithLevel:0.4]];
	[completeTop setFillStartingColor:[[completeTop fillStartingColor] highlightWithLevel:0.4]];
	[completeTop setFillEndingColor:[[completeTop fillEndingColor] highlightWithLevel:0.4]];
	[completeBottom setFillStartingColor:[[completeBottom fillStartingColor] highlightWithLevel:0.4]];
	[completeBottom setFillEndingColor:[[completeBottom fillEndingColor] highlightWithLevel:0.4]];
	[controlTitleField setSolidColor:[NSColor darkGrayColor]];
	[completeTitleField setSolidColor:[NSColor darkGrayColor]];
	[qualityLabel setTextColor:[NSColor darkGrayColor]];
}
- (void)windowDidBecomeKey:(NSNotification *)notification {
	[controlTop setFillStartingColor:[controlTopColor objectAtIndex:0]];
	[controlTop setFillEndingColor:[controlTopColor objectAtIndex:1]];
	[controlBottom setFillStartingColor:[controlBottomColor objectAtIndex:0]];
	[controlBottom setFillEndingColor:[controlBottomColor objectAtIndex:1]];
	[completeTop setFillStartingColor:[completeTopColor objectAtIndex:0]];
	[completeTop setFillEndingColor:[completeTopColor objectAtIndex:1]];
	[completeBottom setFillStartingColor:[completeBottomColor objectAtIndex:0]];
	[completeBottom setFillEndingColor:[completeBottomColor objectAtIndex:1]];
	[controlTitleField setSolidColor:[NSColor blackColor]];
	[completeTitleField setSolidColor:[NSColor blackColor]];
	[qualityLabel setTextColor:[NSColor blackColor]];	
}
@end
