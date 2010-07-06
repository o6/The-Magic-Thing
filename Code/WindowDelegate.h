//
//  WindowDelegate.h
//  The Magic Thing
//
//  Created by Carter Allen on 8/15/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>


@interface WindowDelegate : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet BWGradientBox *controlTop;
	IBOutlet BWGradientBox *controlBottom;
	IBOutlet BWGradientBox *completeTop;
	IBOutlet BWGradientBox *completeBottom;
	IBOutlet BWStyledTextField *controlTitleField;
	IBOutlet BWStyledTextField *completeTitleField;
	IBOutlet BWInsetTextField *qualityLabel;
	
	NSArray *controlTopColor;
	NSArray *controlBottomColor;
	NSArray *completeTopColor;
	NSArray *completeBottomColor;
}
+ (id)sharedInstance;
- (void)setDisplayedState:(int)state;
@end
