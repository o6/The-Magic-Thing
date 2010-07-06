//
//  IconImageView.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/18/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import "IconImageView.h"
@implementation NSImageCell (DraggableImageView)
- (NSImage *)_scaledImage {
	return _scaledImage;
}
@end
@implementation IconImageView
@synthesize iconSize;
- (void)awakeFromNib {
	[self setTarget:self];
	[self setAction:@selector(mouseDown:)];
}
- (NSString *)representedFile {
	return representedFile;
}
- (void)setRepresentedFile:(NSString *)filePath {
	representedFile = [filePath copy];
	id theFamily = [[[IconFamily iconFamily] retain] initWithIconOfFile:representedFile];
	NSImage *fullImage = [theFamily imageWithAllReps];
	[theFamily release];
	NSSize imageSize;
	if (iconSize == 0) {
		iconSize = 128;
	}
	imageSize.width = iconSize;
	imageSize.height = iconSize;
	[fullImage setSize:imageSize];
	[self setImage:fullImage];
}
- (void)mouseDown:(NSEvent *)theEvent {
	if ([theEvent clickCount] >= 2) {
		[[NSWorkspace sharedWorkspace] selectFile:[[NSURL fileURLWithPath:representedFile] path] inFileViewerRootedAtPath:nil];
	}
}
- (void)startDrag:(NSEvent *)event {
    NSPasteboard *pb = [NSPasteboard pasteboardWithName: NSDragPboard];
    NSImage *dragImage;
    NSImage *scaledImage = [[self cell] _scaledImage];
    NSPoint dragPoint;
	
    dragPoint = NSMakePoint(
							([self bounds].size.width - [scaledImage size].width) / 2,
							([self bounds].size.height - [scaledImage size].height) / 2);
	
	
    [pb declareTypes: [NSArray arrayWithObject: NSFilenamesPboardType]
			   owner: self];
	
	[pb setPropertyList:[NSArray arrayWithObject:representedFile] forType:NSFilenamesPboardType];
    dragImage = [[[NSImage alloc] initWithSize: [scaledImage size]]
				 autorelease];
    [dragImage lockFocus];
    [[[self cell] _scaledImage] dissolveToPoint: NSMakePoint(0,0)
									   fraction: .5];
    [dragImage unlockFocus];
	
    [self dragImage: dragImage
				 at: dragPoint
			 offset: NSMakeSize(0,0)
			  event:event
		 pasteboard:pb
			 source: self
		  slideBack: YES];
}
- (void)mouseDragged:(NSEvent *)event {
	if ([self image]) {
		[self startDrag:event];
	}
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
	return YES;
}
@end
