//
//  MKSystemSettingsWindow.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 24.04.13.
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



#import <Cocoa/Cocoa.h>
#import "MKCommon.h"
#import "MKSystemSettingsWindow.h"
#import "MKUI.h"



#define WINDOW_WIDTH  700.0f
#define WINDOW_HEIGHT 88.0f



@interface MKSystemSettingsWindow () <NSWindowDelegate>

@property (nonatomic, assign) BOOL onSettings;
@property (nonatomic, retain) NSWindow *window;
@property (nonatomic, nullable , copy) MKSystemSettingsCallback complete;

- (void)onSystemPreferences:(NSButton *)sender;
- (void)windowWillClose:(NSNotification *)notification;

@end



@implementation MKSystemSettingsWindow


#pragma mark - init & dealloc

- (instancetype)initWithNewStyle:(BOOL)newStyle andCallback:(nullable MKSystemSettingsCallback)callback {
    if ((self = [super init])) {
        self.complete = callback;
        self.onSettings = NO;

        self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(10.0f, 10.0f, WINDOW_WIDTH, WINDOW_HEIGHT) styleMask:NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES];
        self.window.delegate = self;
        self.window.title = BUNDLE_OBJ(@"CFBundleName");

        CGFloat const newHeight = (newStyle) ? 569.0f : 512.0f;
        CGFloat const newShit = (newStyle) ? 0.0f : 10.0f;

        NSImageView *const image = [[[NSImageView alloc] initWithFrame:NSMakeRect(3.0f, WINDOW_HEIGHT - 27.0f - newShit, 686.0f, newHeight)] autorelease];
        image.image = [NSImage imageNamed:(newStyle) ? @"kb_security" : @"kb_assistive"];

        [self.window.contentView addSubview:image];

        MK_WINDOW_SET_CENTER(self.window, WINDOW_WIDTH, (WINDOW_HEIGHT + newHeight));

        NSTextView *const text = [MKUI textViewWithFrame:NSMakeRect(0.0f, (WINDOW_HEIGHT + newHeight) - 40.0f, WINDOW_WIDTH, 16.0f)];
        text.string = (newStyle) ? NSLocalizedString(@"To make Keybroad work, we need your permission to control text input on this computer", @"System Settings") : NSLocalizedString(@"To make Keybroad work, we need Access for assistive devices to be enabled", @"System Settings");

        [self.window.contentView addSubview:text];

        NSTextView *const text2 = [MKUI textViewWithFrame:NSMakeRect(0.0f, 59.0f, WINDOW_WIDTH, 32.0f)];
        text2.string = (newStyle) ? NSLocalizedString(@"Please allow Keybroad to control your computer in the System Preferences →\nSecurity & Privacy → Privacy, then restart Keybroad (this needs to be done only once)", @"System Settings") : NSLocalizedString(@"Please, enable it in the System Preferences → Accessibility,\nthen quit Keybroad and start it again (this needs to be done only once)", @"System Settings");

        [self.window.contentView addSubview:text2];

        NSButton *const settings = [MKUI buttonWithTitle:NSLocalizedString(@"Open System Preferences and quit Keybroad", @"System Settings") target:self action:@selector(onSystemPreferences:) andRect:NSMakeRect(ceil((WINDOW_WIDTH - 350.0f) / 2.0f), 16.0f, 350.0f, 24.0f)];

        [self.window.contentView addSubview:settings];

        [self.window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }

    return self;
}


- (void)dealloc {
    self.complete = nil;
    self.window = nil;

    [super dealloc];
}


#pragma mark - Events

- (void)onSystemPreferences:(NSButton *)sender {
    self.onSettings = YES;

    [self.window close];
}


- (void)windowWillClose:(NSNotification *)notification {
    WEAKIFY(self);

    ASYNCH_MAINTHREAD(^{
        if (selfWeakified.complete)
            selfWeakified.complete(selfWeakified.onSettings);
    });
}


@end
