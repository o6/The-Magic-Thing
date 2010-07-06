//
//  DropView.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/5/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import "DropView.h"


@implementation DropView

- (id)initWithFrame:(NSRect)frame {
	[self setWantsLayer:YES];
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	if (!darkGradient) {
		//[[self animator] setAlphaValue:0.0];
		//[[self animator] setAlphaValue:100.00];
		[[NSImage imageNamed:@"dropView.png"] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
		return;
	} else {
		[NSAnimationContext beginGrouping]; 
		[[NSAnimationContext currentContext] setDuration:2.0f]; 
		//[[NSImage imageNamed:@"dropViewBlue.png"] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy  fraction:1.0];
		[[self animator] setAlphaValue:0.0];
		[NSAnimationContext endGrouping];
		//[[self animator] setAlphaValue:100.00];
	}
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	//NSLog([[sender draggingPasteboard] name]);
	[[sender draggingPasteboard] types];
	NSArray *fileNames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	if ([fileNames count] != 1) {
		return NSDragOperationNone;
	}
	NSString *extension = [[[fileNames objectAtIndex:0] pathExtension] lowercaseString];
	if (![[self supportedFileExtensions] containsObject:extension])
		return NSDragOperationNone;
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
		darkGradient = YES;
		[self setNeedsDisplay:YES];
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	darkGradient = NO;
	[self setNeedsDisplay:YES];
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	darkGradient = NO;
	[self setNeedsDisplay:YES];
    //we don't do anything in our implementation
    //this could be ommitted since NSDraggingDestination is an infomal
	//protocol and returns nothing
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	[[sender draggingPasteboard] types];
	NSArray *fileNames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	if ([fileNames count] != 1) {
		return NO;
	}
	NSString *extension = [[[fileNames objectAtIndex:0] pathExtension] lowercaseString];
	if (![[self supportedFileExtensions] containsObject:extension])
		return NO;
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *paste = [sender draggingPasteboard];
	//gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
	//a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
	
    if (nil == carriedData)
    {
        //the operation failed for some reason
        NSRunAlertPanel(@"Paste Error", @"Sorry, but the past operation failed", 
						nil, nil, nil);
        return NO;
    }
    else
    {
        //the pasteboard was able to give us some meaningful data
        if ([desiredType isEqualToString:NSFilenamesPboardType])
        {
            //we have a list of file names in an NSData object
            NSArray *fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];
			//be caseful since this method returns id.  
			//We just happen to know that it will be an array.
			if ([fileArray count] != 1) {
				return NO;
			}
            NSString *path = [fileArray objectAtIndex:0];
			//assume that we can ignore all but the first path in the list
			id theFamily = [[[IconFamily iconFamily] retain] initWithIconOfFile:path];
			NSImage *fullImage = [theFamily imageWithAllReps];
			[theFamily release];
			NSSize imageSize;
			imageSize.width = 128;
			imageSize.height = 128;
			[fullImage setSize:imageSize];
			[iconView setImage:fullImage];
			[fileName setStringValue:[[NSFileManager defaultManager] displayNameAtPath:path]];
			[conversionController setFileName:path];
			NSLog(@"File dropped: %@", path);
        }
        else
        {
            //this can't happen
            NSAssert(NO, @"This can't happen");
            return NO;
        }
    }
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	darkGradient = NO;
	[self setNeedsDisplay:YES];
	[conversionController resetUI];
	[[WindowDelegate sharedInstance] setDisplayedState:1];
	[tabView setTransitionStyle:AnimatingTabViewSwipeTransitionStyle];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:1]];
}

- (NSArray *)supportedFileExtensions {
	return [NSArray arrayWithObjects:@"mov", @"mp4", @"flv", @"swf", @"wmv", @"m4v", @"avi", nil];
}
- (void)openFile:(NSString *)file {
	id theFamily = [[[IconFamily iconFamily] retain] initWithIconOfFile:file];
	NSImage *fullImage = [theFamily imageWithAllReps];
	[theFamily release];
	NSSize imageSize;
	imageSize.width = 128;
	imageSize.height = 128;
	[fullImage setSize:imageSize];
	[iconView setImage:fullImage];
	[fileName setStringValue:[[NSFileManager defaultManager] displayNameAtPath:file]];
	[conversionController setFileName:file];
	darkGradient = NO;
	[self setNeedsDisplay:YES];
	[conversionController resetUI];
	[[WindowDelegate sharedInstance] setDisplayedState:1];
	[tabView setTransitionStyle:AnimatingTabViewSwipeTransitionStyle];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:1]];
}
- (void)dealloc
{
    [self unregisterDraggedTypes];
    [super dealloc];
}
@end
