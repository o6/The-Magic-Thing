//
//  IconImageView.h
//  The Magic Thing
//
//  Created by Carter Allen on 8/18/09.
//  Copyright 2009 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IconFamily.h"

@interface IconImageView : NSImageView {
	int iconSize;
	NSString *representedFile;
}
- (NSString *)representedFile;
- (void)setRepresentedFile:(NSString *)filePath;
@property(assign) int iconSize;
@end
