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

@property (nonatomic, nullable, retain) MKCapsSettingController *capsController;
@property (nonatomic, retain) NSStatusItem *mainMenu;
@property (nonatomic, retain) MKStatusItemView *view;

@end




@implementation MKMenuController


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init])) {
        self.mainMenu = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
        self.view = [[[MKStatusItemView alloc] initWithStatusBarItem:self.mainMenu] autorelease];
        self.view.delegate = self;

        [self.mainMenu setView:self.view];
        [self updateImages];

        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(themeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    }

    return self;
}


- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];

    self.capsController = nil;

    [_view release];
    [_mainMenu release];

    [super dealloc];
}


#pragma mark - AppleInterfaceThemeChangedNotification

- (void)themeChanged:(NSNotification *)notification {
    [self updateImages];
}


#pragma mark - Public Methods

- (void)updateImages {
    BOOL const inactive = [SETTINGS isExcluded:SHARED_APP.frontmostProcessBundleID];
    BOOL const off = !SETTINGS.active;
    BOOL const isDarkTheme = SETTINGS.currentInterfaceType == MKSettingsInterfaceTypeDark;
    NSString *suffix = @"";

    if (off) {
        if (inactive) {
            suffix = @"_off_inactive";
        }
        else {
            suffix = @"_off";
        }
    }
    else {
        if (inactive) {
            suffix = isDarkTheme ? @"_inactive_alt" : @"_inactive";
        }
    }

    if (suffix.length < 1) {
        suffix = isDarkTheme ? @"_alt" : @"";
    }

    NSString *const imageName = FORMAT(@"%@%@", @"kb_menubar", suffix);

    self.view.image = [NSImage imageNamed:imageName];
    self.view.alternateImage = [NSImage imageNamed:FORMAT(@"kb_menubar%@_alt", inactive ? @"_inactive" : @"")];
}


#pragma mark - MKStatusItemViewDelegate

- (void)statusItemViewDidClick:(MKStatusItemView *)itemView {
    NSMenu *const menu = [self.class createMenuForTarget:self alt:NO];

    [self.view popUpMenu:menu];
}


- (void)statusItemViewDidAltClick:(MKStatusItemView *)itemView {
    NSMenu *const menu = [self.class createMenuForTarget:self alt:YES];

    [self.view popUpMenu:menu];
}


- (void)statusItemViewDidRightClick:(MKStatusItemView *)itemView {
    [self onToggle:nil];
}


#pragma mark - Menu

+ (NSMenuItem *)menuItemWithTitle:(NSString *)title target:(id)target action:(SEL)action checked:(BOOL)checked andHotkey:(NSString *)hotkey {
    NSMenuItem *const item = [[[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:hotkey] autorelease];
    item.target = target;
    item.state = (checked) ? NSOnState : NSOffState;

    return item;
}


+ (NSMenu *)createMenuForTarget:(id<NSMenuDelegate>)target alt:(BOOL)alt {
    NSMenu *const menu = [[[NSMenu alloc] init] autorelease];
    menu.delegate = target;

    BOOL const isExcluded = [SETTINGS isExcluded:SHARED_APP.frontmostProcessBundleID];
    NSString *const strExc = FORMAT(@"Turn KB %@ for this App", isExcluded ? @"on" : @"off");

    [menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Activate Keybroad", @"Menu") target:target action:@selector(onToggle:) checked:SETTINGS.active andHotkey:@""]];
    [menu addItem:[self menuItemWithTitle:NSLocalizedString(strExc, @"Menu") target:target action:@selector(onExclude:) checked:NO andHotkey:@""]];
    [menu addItem:NSMenuItem.separatorItem];

    NSString *lastGr = nil;
    BOOL bFirst = YES;

    for (MKPreset *const preset in PRESETS.presets) {
        if (preset.hidden) {
            continue;
        }

        NSUInteger const index = [PRESETS.presets indexOfObject:preset];
        NSMenuItem *const item = [self menuItemWithTitle:NSLocalizedString(preset.title, @"Menu") target:target action:@selector(onPreset:) checked:preset.active andHotkey:@""];
        item.tag = index;

        if ((preset.group || lastGr) && ![preset.group isEqualToString:lastGr] && !bFirst) {
            [menu addItem:NSMenuItem.separatorItem];
        }

        if (bFirst) {
            bFirst = NO;
        }

        lastGr = preset.group;

        [menu addItem:item];
    }

    [menu addItem:NSMenuItem.separatorItem];

    if (MKLayout.layout.layouts.count > 1) {
        [menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Caps Lock settings...", @"Menu") target:target action:@selector(onCapsSettings:) checked:NO andHotkey:@""]];
    }

    [menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Support...", @"Menu") target:target action:@selector(onSupport:) checked:NO andHotkey:@""]];
    [menu addItem:NSMenuItem.separatorItem];
    [menu addItem:[self menuItemWithTitle:NSLocalizedString(@"Quit Keybroad", @"Menu") target:target action:@selector(onQuit:) checked:NO andHotkey:@""]];

    return menu;
}


#pragma mark - Menu Actions

- (void)onQuit:(NSMenuItem *)sender {
    NSLog(@"App quit");

    SETTINGS.startup = NO;

    [NSApplication.sharedApplication terminate:nil];
}


- (void)onCapsSettings:(NSMenuItem *)sender {
    if (!self.capsController) {
        WEAKIFY(self);

        self.capsController = [[[MKCapsSettingController alloc] initWithCallback:^{
            selfWeakified.capsController = nil;
        }] autorelease];
    }
    else {
        [NSApp activateIgnoringOtherApps:YES];
    }
}


- (void)onExclude:(NSMenuItem *)sender {
    NSString *const bundleId = [SHARED_APP frontmostProcessBundleID];
    BOOL const isExcluded = [SETTINGS isExcluded:bundleId];

    if (isExcluded) {
        [SETTINGS removeExcludeApp:bundleId];
    }
    else {
        [SETTINGS addExcludeApp:bundleId];
    }

    [KEYSTORE invalidate];
    [self updateImages];
}


- (void)onToggle:(NSMenuItem *)sender {
    SETTINGS.active = !SETTINGS.active;

    [KEYSTORE invalidate];
    [self updateImages];
}


- (void)onPreset:(NSMenuItem *)sender {
    MKPreset *const preset = PRESETS.presets[sender.tag];
    preset.active = !preset.active;
    NSString *const group = preset.group;

    if (group && group.length > 0) {
        for (MKPreset *const aPreset in PRESETS.presets) {
            NSString *const aGroup = aPreset.group;

            if (aGroup && [aGroup isEqualToString:group] && [aPreset isNotEqualTo:preset]) {
                aPreset.active = !preset.active;
            }
        }
    }

    [KEYSTORE invalidate];
}


- (void)onSupport:(NSMenuItem *)sender {
    [NSWorkspace.sharedWorkspace openURL:URL(BUNDLE_OBJ(@"MKSupportURL"))];
    [KEYSTORE invalidate];
}


@end
