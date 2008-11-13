//
//  LayerLinkPlugin.h
//  LayerLinkPlugin
//
//  Created by Erich Ocean on 10/4/04.
//  Copyright (c) 2004 Erich Atlas Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LayerLinkPlugin : NSObject
{

}

+ (void)installMenuItems;
+ (void)setupOpenPanel;
+ (void)createAboutWindow;

+ (void)closeAboutPanel:(NSNotification *)note;
+ (BOOL)windowShouldClose:(id)sender;

+ (IBAction)importIllustratorDocument:(id)sender;
+ (IBAction)showAboutWindow:(id)sender;
+ (IBAction)launchLicenseControl:(id)sender;
+ (IBAction)gotoLayerLinkPurchase:(id)sender;

@end
