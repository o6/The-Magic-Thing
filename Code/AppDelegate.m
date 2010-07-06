//
//  AppDelegate.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/5/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize window;
- (void)awakeFromNib
{
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
    [contentView addSubview:[self currentView]];
	
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromBottom];
	//[transition setType:kCATransitionMoveIn];
    //[transition setSubtype:kCATransitionFromBottom];
	
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition 
                                                    forKey:@"subviews"];
    [contentView setAnimations:ani];
}

@end
