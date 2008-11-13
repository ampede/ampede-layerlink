//
//  AboutView.m
//  LayerLinkPlugin
//
//  Created by Erich Ocean on Sun Jul 25 2004.
//  Copyright (c) 2004 Erich Atlas Ocean. All rights reserved.
//

#import "AboutView.h"
#import "LayerLinkPlugin.h"


@implementation AboutView

- (void)
mouseDown:(NSEvent *)theEvent;
{
//	NSLog(@"-[AboutView mouseDown:] called");
	[LayerLinkPlugin closeAboutPanel:nil];
}

@end
