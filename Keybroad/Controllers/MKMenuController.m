//
//  MKMenuController.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 25.10.13.
//  Copyright (c) 2013 Mikhail Kalinin. All rights reserved.
//
//  This file is part of Keybroad app.
//
//  Keybroad is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Keybroad is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.




#import "MKMenuController.h"
#import "MKCommon.h"
#import "MKSettings.h"
#import "MKLayout.h"
#import "MKKeyStore.h"
#import "MKPresetManager.h"
#import "MKSharedApplication.h"
#import "MKCapsSettingController.h"




@interface MKMenuController () <NSMenuDelegate, MKStatusItemViewDelegate>

@property (nonatomic, retain) NSStatusItem * mainMenu;
@property (nonatomic, retain) MKCapsSettingController * capsController;
@property (nonatomic, retain) MKStatusItemView * view;

@end




@implementation MKMenuController


#pragma mark - init & dealloc

- (instancetype)init {
	if ((self = [super init])) {
		self.mainMenu = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
		self.view = [[[MKStatusItemView alloc] initWithStatusBarItem:self.mainMenu] autorelease];
		self.view.delegate = self;

		[self.mainMenu setView:self.view];
		[self setImages];

        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(themeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
	}

	return self;
}


- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];

    self.capsController = nil;
    self.view = nil;
    self.mainMenu = nil;

	[super dealloc];
}


#pragma mark - AppleInterfaceThemeChangedNotification

- (void)themeChanged:(NSNotification *)notification {
    [self setImages];
}


#pragma mark - Public Methods

- (void)setImages {
	BOOL inactive = [SETTINGS isExcluded:SHARED_APP.frontmostProcessBundleID];
	BOOL off = !SETTINGS.active;
    BOOL isDarkTheme = SETTINGS.currentInterfaceType == MKSettingsInterfaceTypeDark;
	NSString * suffix = @"";

	if (off) {
		if (inactive)
			suffix = @"_off_inactive";
		
		else
			suffix = @"_off";
	}
	else
		if (inactive)
            suffix = isDarkTheme ? @"_inactive_alt" : @"_inactive";

    if (suffix.length < 1)
        suffix = isDarkTheme ? @"_alt" : @"";

	NSString * imageName = FORMAT(@"%@%@", @"kb_menubar", suffix);

	self.view.image = [NSImage imageNamed:imageName];
	self.view.alternateImage = [NSImage imageNamed:FORMAT(@"kb_menubar%@_alt", inactive ? @"_inactive" : @"")];
}


#pragma mark - MKStatusItemViewDelegate

- (void)statusItemViewDidClick:(MKStatusItemView *)itemView {
	[self createMenu:NO];
}


- (void)statusItemViewDidAltClick:(MKStatusItemView *)itemView {
	[self createMenu:YES];
}


- (void)statusItemViewDidRightClick:(MKStatusItemView *)itemView {
	[self onToggle:nil];
}


- (void)statusItemViewDidRightAltClick:(MKStatusItemView *)itemView {
	
}


#pragma mark - Menu

- (NSMenuItem *)menuItemWithTitle:(NSString *)title action:(SEL)action checked:(BOOL)checked andHotkey:(NSString *)hotkey {
	NSMenuItem * item = [[[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:hotkey] autorelease];
	item.target = self;
    item.state = (checked) ? NSOnState : NSOffState;
	
	return item;
}


- (void)createMenu:(BOOL)alt {
	NSMenu * menu = [[[NSMenu alloc] init] autorelease];
	menu.delegate = self;

	BOOL isExcluded = [SETTINGS isExcluded:SHARED_APP.frontmostProcessBundleID];
	NSString * strExc = FORMAT(@"Turn KB %@ for this App", isExcluded ? @"on" : @"off");
	
	[menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Activate Keybroad", @"Menu") action:@selector(onToggle:) checked:SETTINGS.active andHotkey:@""]];
	[menu addItem:[self menuItemWithTitle:NSLocalizedString(strExc, @"Menu") action:@selector(onExclude:) checked:NO andHotkey:@""]];
	[menu addItem:NSMenuItem.separatorItem];

	NSString * lastGr = nil;
	BOOL bFirst = YES;

	for (MKPreset * preset in PRESETS.presets) {
		if (preset.hidden)
			continue;

		NSUInteger index = [PRESETS.presets indexOfObject:preset];
		NSMenuItem * item = [self menuItemWithTitle:NSLocalizedString(preset.title, @"Menu") action:@selector(onPreset:) checked:preset.active andHotkey:@""];
		item.tag = index;
		
		if ((preset.group || lastGr) && ![preset.group isEqualToString:lastGr] && !bFirst)
			[menu addItem:NSMenuItem.separatorItem];
		
		if (bFirst)
			bFirst = NO;
		
		lastGr = preset.group;
		
		[menu addItem:item];
	}

	[menu addItem:NSMenuItem.separatorItem];

	if (LAYOUT.layouts.count > 1)
		[menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Caps Lock settings...", @"Menu") action:@selector(onCapsSettings:) checked:NO andHotkey:@""]];

	[menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Support...", @"Menu") action:@selector(onSupport:) checked:NO andHotkey:@""]];
	[menu addItem:NSMenuItem.separatorItem];
	[menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Quit Keybroad", @"Menu") action:@selector(onQuit:) checked:NO andHotkey:@""]];
	
	[(MKStatusItemView *)self.mainMenu.view popUpMenu:menu];
}


#pragma mark - Menu Actions

- (void)onQuit:(NSMenuItem *)sender {
	NSLog(@"App quit");
	SETTINGS.startup = NO;

	[NSApplication.sharedApplication terminate:nil];
}


- (void)onCapsSettings:(NSMenuItem *)sender {
	if (!self.capsController)
		self.capsController = [[[MKCapsSettingController alloc] initWithCallback:^{
			self.capsController = nil;
		}] autorelease];

	else
		[NSApp activateIgnoringOtherApps:YES];
}


- (void)onExclude:(NSMenuItem *)sender {
	NSString * bundleId = [SHARED_APP frontmostProcessBundleID];
	BOOL isExcluded = [SETTINGS isExcluded:bundleId];

	if (isExcluded)
		[SETTINGS removeExcludeApp:bundleId];

    else
		[SETTINGS addExcludeApp:bundleId];

	[KEYSTORE invalidate];
	[self setImages];
}


- (void)onToggle:(NSMenuItem *)sender {
	SETTINGS.active = !SETTINGS.active;

	[KEYSTORE invalidate];
	[self setImages];
}


- (void)onPreset:(NSMenuItem *)sender {
	MKPreset * preset = PRESETS.presets[sender.tag];
	preset.active = !preset.active;
	NSString * group = preset.group;
	
	if (group && group.length > 0)
		for (MKPreset * pres in PRESETS.presets) {
			NSString * pGroup = pres.group;

			if (pGroup && [pGroup isEqualToString:group] && [pres isNotEqualTo:preset])
				pres.active = !preset.active;
		}

	[KEYSTORE invalidate];
}


- (void)onSupport:(NSMenuItem *)sender {
	[NSWorkspace.sharedWorkspace openURL:URL(BUNDLE_OBJ(@"MKSupportURL"))];
	[KEYSTORE invalidate];
}


@end
