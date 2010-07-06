//
//  QuitController.h
//  The Magic Thing
//
//  Created by Carter Allen on 8/7/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConversionController.h"
#import "DropView.h"


@interface QuitController : NSObject {
	NSMutableArray *processes;
	IBOutlet NSWindow *mainWindow;
	IBOutlet DropView *dView;
}
+ (id)controller;
- (void)addProcess:(NSString *)process;
- (void)removeProcess:(NSString *)process;
@end
