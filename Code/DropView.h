//
//  DropView.h
//  The Magic Thing
//
//  Created by Carter Allen on 8/5/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
//#import <QuartzCore/CoreAnimation.h>
#import "AnimatingTabView.h"
#import "IconFamily.h"
#import "WindowDelegate.h"

@class ConversionController;
@interface DropView : NSView {
	NSImageView *currentImageView; 
	BOOL darkGradient;
	IBOutlet NSWindow *mainWindow;
	IBOutlet AnimatingTabView *tabView;
	IBOutlet NSImageView *iconView;
	IBOutlet BWStyledTextField *fileName;
	IBOutlet ConversionController *conversionController;
	IBOutlet NSImageView *backView;
}
- (NSArray *)supportedFileExtensions;
- (void)openFile:(NSString *)file;
@end
