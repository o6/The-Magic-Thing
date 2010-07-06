//
//  main.m
//  The Magic Thing
//
//  Created by Carter Allen on 8/5/09.
//  Copyright Opt-6 Products, LLC 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConversionController.h"

int main(int argc, char *argv[])
{
	if((GetCurrentEventKeyModifiers() & optionKey)!=0) {
		[[ConversionController controller] setBetaLog:YES];
	}
    return NSApplicationMain(argc,  (const char **) argv);
}
