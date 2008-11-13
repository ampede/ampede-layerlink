//
//  LayerLinkPlugin.m
//  LayerLinkPlugin
//
//  Created by Erich Ocean on 10/4/04.
//  Copyright (c) 2004 Erich Atlas Ocean. All rights reserved.
//

#import "LayerLinkPlugin.h"

#import "AboutView.h"

#ifndef LICENSE_CONTROL_ON
  #warning application is not enabled for shipping; turn LICENSE_CONTROL_ON
#endif

#ifdef LICENSE_CONTROL_ON
  #define LAYERLINK_APP_PATH CFSTR("/Library/Application Support/SIMBL/Plugins/LayerLink.bundle/Contents/layerlinkd.app")
#else
  #define LAYERLINK_APP_PATH CFSTR("/Users/ocean/Build/LayerLink.app")
#endif

BOOL static LayerLinkIsLicensed = NO;

void LaunchAmpede()
{
	const LSLaunchFlags launchFlags = kLSLaunchDontAddToRecents | kLSLaunchDontSwitch;
	LSLaunchURLSpec launchSpec = { NULL, NULL, NULL, launchFlags, NULL };
	OSStatus err = noErr;
	
	launchSpec.appURL = CFURLCreateWithFileSystemPath(
        					kCFAllocatorDefault,
        					LAYERLINK_APP_PATH,
        					kCFURLPOSIXPathStyle,
        					true );

	err = LSOpenFromURLSpec( &launchSpec, NULL );
	
	if ( err != noErr ) NSLog(@"LayerLink error: Launch Services failed to launch the layerlinkd daemon. Error: %d", err);
}

static id panel = nil;
static NSWindow *aboutWindow = nil;
static BOOL aboutWindowIsVisible = NO;
static NSTimer *timer = nil;

@implementation LayerLinkPlugin

+ (void) closeAboutPanel:(NSNotification *)note;
{
//	NSLog(@"+[LayerLinkPlugin closeAboutPanel:] called");
	if ( aboutWindowIsVisible )
	{
		aboutWindowIsVisible = NO;
		[self windowShouldClose:nil];
	}
}

+ (void) load;
{
	[self installMenuItems];
	[self createAboutWindow];
	
	[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(terminateLayerLink:)
			name:NSApplicationWillTerminateNotification
			object:nil];

	[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(layerLinkIsLicensed:)
			name:@"com.ampede.layerlink.licensed"
			object:nil];

    LaunchAmpede();
}

//+ (void) install;
//{
//    LaunchAmpede();
//}

+ (void) layerLinkIsLicensed:(NSNotification *)note;
{
	NSLog(@"LayerLink is licensed.");
	
	LayerLinkIsLicensed = YES;
	
	// update Register LayerLink... menu item
    NSMenu *mainMenu = nil;
    
    if ( (mainMenu = [NSApp mainMenu]) != nil ) {
        NSMenuItem *item;
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSMenu *appSubmenu = [[[mainMenu itemArray] objectAtIndex:0] submenu];

		item = [appSubmenu itemWithTitle:NSLocalizedStringFromTableInBundle(
												@"Register LayerLink...",
												@"LayerLinkPluginTable",
												bundle,
												@"Launch LicenseControl application" )];
												
		[item setTitle:NSLocalizedStringFromTableInBundle(
							@"Unregister LayerLink...",
							@"LayerLinkPluginTable",
							bundle,
							@"Launch LicenseControl application" )];

		item = [appSubmenu	itemWithTitle:NSLocalizedStringFromTableInBundle(
												@"Purchase LayerLink...",
												@"LayerLinkPluginTable",
												bundle,
												@"Go to LayerLink purchase web page at ampede.com" )];
		[appSubmenu removeItem:item];
	}
}

+ (void) terminateLayerLink:(NSNotification *)note;
{
	[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.ampede.layerlink.terminate"
			object:nil];
}

#define CONTENT_WIDTH 600
#define CONTENT_HEIGHT 350

+ (void) createAboutWindow;
{
	NSRect screenRect = [[NSScreen mainScreen] frame];
	
	float bottomLeftX = ( screenRect.size.width / 2 ) - ( CONTENT_WIDTH / 2 );
	float bottomLeftY = ( screenRect.size.height * 0.635 ) - ( CONTENT_HEIGHT / 2 );
	
	NSRect contentRect = NSMakeRect( bottomLeftX, bottomLeftY, CONTENT_WIDTH, CONTENT_HEIGHT );
	
	aboutWindow = [[NSWindow alloc]
							initWithContentRect:contentRect
							styleMask:NSBorderlessWindowMask
							backing:NSBackingStoreBuffered
							defer:YES
							screen:[NSScreen mainScreen]];
	[aboutWindow setHasShadow:YES];
	
	AboutView *av = [[AboutView alloc] initWithFrame:contentRect];
	[aboutWindow setContentView:av];
	
	NSBundle *bundle = [NSBundle bundleForClass:self];
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"about" ofType:@"png"]];
	[av setImage:image];
	[image release];
	
	[aboutWindow setLevel:CGShieldingWindowLevel()];
	
	[aboutWindow setDelegate:self];

	[[NSNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(closeAboutPanel:)
				name:NSApplicationWillResignActiveNotification
				object:nil];
}

+ (void) setupOpenPanel;
{
	NSBundle *bundle = [NSBundle bundleForClass:self];
	panel = [[NSOpenPanel openPanel] retain];
	
	[panel setTitle:NSLocalizedStringFromTableInBundle(@"Choose an Illustrator 10 or Later Document", @"LayerLinkPluginTable", bundle, @"Illustrator file chooser dialog window title" )];
	
	[panel setPrompt:NSLocalizedStringFromTableInBundle(
								@"Import as Project",
								@"LayerLinkPluginTable",
								bundle,
								@"Illustrator file chooser dialog accept button"  )];
}

+ (BOOL) hasNeverBeenLicensed;
{
	NSUserDefaults *ud = [[[NSUserDefaults alloc] init] autorelease];
	[ud addSuiteNamed:@"com.ampede.layerlink"];
	
	BOOL LayerLink_hasBeenLicensed = [ud boolForKey:@"LayerLink::hasBeenLicensed"];
	NSLog(@"LayerLink_hasBeenLicensed is %d", LayerLink_hasBeenLicensed);
	
	BOOL hasNeverBeenLicensed = ( LayerLink_hasBeenLicensed ) ? NO : YES;
	NSLog(@"hasNeverBeenLicensed is %d", hasNeverBeenLicensed);
	
	return hasNeverBeenLicensed;
}

// derived from FSAController.m in FScriptAnywhereSIMBL
+ (void) installMenuItems;
{
    static BOOL alreadyInstalled = NO;
	BOOL useMotion2MenuItem = NO;
    NSMenu *mainMenu = nil;
    
    if (!alreadyInstalled && ((mainMenu = [NSApp mainMenu]) != nil)) {
        NSMenuItem *item;
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSMenu *appSubmenu = [[[mainMenu itemArray] objectAtIndex:0] submenu];
		NSMenu *fileMenu = [[[mainMenu itemArray] objectAtIndex:1] submenu];
		
#ifndef LICENSE_CONTROL_ON
		NSLog(@"%@", appSubmenu);
		NSLog(@"%@", fileMenu);
#endif		
		// We find the localized "Import as Project..." menu item.
		// Currently, I include the localizations in the LayerLinkPluginTable.strings table.
		// It might be better to get them directly from the Motion bundle, to
		// better cope with future changes.
		int fileInsertIndex = [fileMenu indexOfItemWithTitle:
		                                        NSLocalizedStringFromTableInBundle(
													@"Import as Project...",
													@"LayerLinkPluginTable",
													bundle,
													@"Import as Project... menu item in Retail Motion"  )];
		
		if ( fileInsertIndex = 1 )
		{
			useMotion2MenuItem = YES;
			NSLog(@"Motion 2 detected.");
			
			// try Motion 2 menu item names
			fileInsertIndex = [fileMenu indexOfItemWithTitle:
		                                        NSLocalizedStringFromTableInBundle(
													@"Motion 2 Import as Project...",
													@"LayerLinkPluginTable",
													bundle,
													@"Import as Project... menu item in Retail Motion 2"  )];
		}
		
        // Succeed or fail, we do not try again.
        alreadyInstalled = YES;
		
		// Add the items in the File menu.
		if ( useMotion2MenuItem == NO )
		{
			item = [fileMenu	insertItemWithTitle:
										NSLocalizedStringFromTableInBundle(
												@"Import Illustrator as Project...",
												@"LayerLinkPluginTable",
												bundle,
												@"Import an Illustrator document as a Motion project"  )
								action:@selector(importIllustratorDocument:)
								keyEquivalent:@"I"
								atIndex:(fileInsertIndex + 1)];
		}
		else // the menu has changed in Motion 2; use the appropriate '...' representation for Motion 2
		{
			item = [fileMenu	insertItemWithTitle:
										NSLocalizedStringFromTableInBundle(
												@"Motion 2 Import Illustrator as Project...",
												@"LayerLinkPluginTable",
												bundle,
												@"Import an Illustrator document as a Motion project in Motion 2"  )
								action:@selector(importIllustratorDocument:)
								keyEquivalent:@"I"
								atIndex:(fileInsertIndex + 1)];
		}
		[item setKeyEquivalentModifierMask:( NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask )];
		[item setTarget:self];

        // really should compute insertIndex dynamically, but this is working fine for now
		int insertIndex = 4;
		
		// Add the items in the Application menu.
		item = [appSubmenu	insertItemWithTitle:
									NSLocalizedStringFromTableInBundle(
											@"About LayerLink",
											@"LayerLinkPluginTable",
											bundle,
											@"Open LayerLink About window"  )
							action:@selector(showAboutWindow:)
							keyEquivalent:@""
							atIndex:insertIndex];
		[item setTarget:self];
		insertIndex++;
		
		item = [appSubmenu	insertItemWithTitle:
									NSLocalizedStringFromTableInBundle(
											@"Register LayerLink...",
											@"LayerLinkPluginTable",
											bundle,
											@"Launch LicenseControl application"  )
							action:@selector(launchLicenseControl:)
							keyEquivalent:@""
							atIndex:insertIndex];
		[item setTarget:self];
		insertIndex++;
		
		item = [appSubmenu	insertItemWithTitle:
									NSLocalizedStringFromTableInBundle(
											@"Purchase LayerLink...",
											@"LayerLinkPluginTable",
											bundle,
											@"Go to LayerLink purchase web page at ampede.com"  )
							action:@selector(gotoLayerLinkPurchase:)
							keyEquivalent:@""
							atIndex:insertIndex];
		[item setTarget:self];
		insertIndex++;
		
		[appSubmenu insertItem:[NSMenuItem separatorItem] atIndex:insertIndex];

#ifndef LICENSE_CONTROL_ON
		NSLog(@"%@", appSubmenu);
		NSLog(@"%@", fileMenu);
#endif
	}
}

+ (IBAction) importIllustratorDocument:(id)sender;
{
//	NSLog(@"importIllustratorDocument: called");
	
		// put up nag screen
#ifdef LICENSE_CONTROL_ON
	if ( !LayerLinkIsLicensed )
	{
		Class NSProAlert = NSClassFromString(@"NSProAlert");
		[NSProAlert	errorAlert:@"LayerLink is Unlicensed."
					withDetails:@"Choose 'Motion > Register LayerLink...' to activate, or choose 'Motion > Purchase LayerLink...' to get a license. LayerLink has a 30-day money-back guarantee so you can try out the plugin."];
	}
	else
#endif
	{
		if (!panel) [self setupOpenPanel];

		[panel	beginForDirectory:nil
					file:nil
					types:[NSArray arrayWithObjects:@"ai", @"PDF ", nil]
					modelessDelegate:self
					didEndSelector:@selector(getChosenFileAndImportProject:)
					contextInfo:NULL];
	}
}

+ (void) getChosenFileAndImportProject:(void *)contextInfo;
{
//	NSLog(@"getChosenFileAndImportProject: called");
	
	// tell LayerLink to import the chosen file as a Motion project
	[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.ampede.layerlink.handleImportRequest"
			object:[[panel URL] absoluteString]];
}

+ (IBAction) showAboutWindow:(id)sender;
{
//	NSLog(@"showAboutWindow: called");

	[aboutWindow orderFront:nil];
	aboutWindowIsVisible = YES;
}

+ (IBAction) launchLicenseControl:(id)sender;
{
//	NSLog(@"launchLicenseControl: called");
	
	[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.ampede.layerlink.launchLicenseControl"
			object:nil];
}

+ (IBAction) gotoLayerLinkPurchase:(id)sender;
{
//	NSLog(@"gotoLayerLinkPurchase: called");
	
	NSURL *url = [NSURL URLWithString:@"http://www.ampede.com/layerlink/buy.html"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

+ (BOOL) windowShouldClose:(id)sender;
{
    timer = [[NSTimer
					scheduledTimerWithTimeInterval:0.05
					target:self
					selector:@selector(fadeOut:)
					userInfo:nil
					repeats:YES] retain];
    
    return NO;
}

+ (void) fadeOut:(NSTimer *)theTimer;
{
    if ( [aboutWindow alphaValue] > 0.0 ) [aboutWindow setAlphaValue:[aboutWindow alphaValue] - 0.2];
    else {
        [timer invalidate];
        [timer release]; timer = nil;
        
        [aboutWindow orderOut:nil];
        
        [aboutWindow setAlphaValue:1.0]; // Make the window fully opaque again for next time.
    }
}

@end
