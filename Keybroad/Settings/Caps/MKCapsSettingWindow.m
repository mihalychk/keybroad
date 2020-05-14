//
//  MKCapsSettingWindow.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 03.11.13.
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
#import "MKCapsSettingWindow.h"
#import "MKCommon.h"
#import "MKTableView.h"
#import "MKUI.h"



#define WINDOW_WIDTH  500.0f
#define WINDOW_HEIGHT 340.0f
#define BACK_HEIGHT   80.0f
#define MK_CAPSLOCK_CATEGORY_STRING   @"Caps Lock Settings"



@interface MKCapsSettingWindow () <MKTableViewDelegate>

@property (nonatomic, nullable, strong) NSButton *checkbox;
@property (nonatomic, nullable, strong) NSButton *doneButton;
@property (nonatomic, nullable, strong) MKTableView *tableOff;
@property (nonatomic, nullable, strong) MKTableView *tableOn;
@property (nonatomic, nullable, strong) NSTextView *textNote;
@property (nonatomic, nullable, strong) NSTextView *textOff;
@property (nonatomic, nullable, strong) NSTextView *textOn;

- (void)setCapsLayout:(nullable NSString *)layoutName forTable:(MKTableView *)table;

@end



@implementation MKCapsSettingWindow


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init])) {
        // Window
        _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(10.0f, 10.0f, WINDOW_WIDTH, WINDOW_HEIGHT) styleMask:NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:YES];
        self.window.releasedWhenClosed = NO;
        self.window.title = BUNDLE_OBJ(@"CFBundleName");

        self.window.contentView.wantsLayer = YES;
        self.window.contentView.layer.masksToBounds = YES;

        NSView *const back = [[NSView alloc] initWithFrame:NSMakeRect(0.0f, WINDOW_HEIGHT - BACK_HEIGHT, WINDOW_WIDTH, BACK_HEIGHT)];
        back.wantsLayer = YES;
        back.layer.backgroundColor = NSColor.controlColor.CGColor;
        back.layer.masksToBounds = YES;

        [self.window.contentView addSubview:back];

        // Checkbox
        NSString *const checkboxTitle = NSLocalizedString(@"Use Caps Lock to switch input sources", MK_CAPSLOCK_CATEGORY_STRING);
        self.checkbox = [MKUI checkboxWithTitle:checkboxTitle target:self action:@selector(onUse:)];

        [back addSubview:self.checkbox];

        // Text Note
        NSString *const textNoteText = NSLocalizedString(@"Please relogin or restart your computer to apply changes", MK_CAPSLOCK_CATEGORY_STRING);
        self.textNote = [MKUI textViewWithText:textNoteText frame:NSMakeRect(0.0f, 0.0f, WINDOW_WIDTH, 32.0f)];

        [back addSubview:self.textNote];

        // Text Caps On
        NSRect const textRect = NSMakeRect(0.0f, 0.0f, 191.0f, 32.0f);
        NSString *const textOnText = FORMAT(@"%@ ●", NSLocalizedString(@"Caps Lock On", MK_CAPSLOCK_CATEGORY_STRING));
        self.textOn = [MKUI textViewWithText:textOnText frame:textRect];

        [self.textOn setTextColor:RGB(0.0f, 1.0f, 0.77f) range:NSMakeRange(self.textOn.string.length - 1, 1)];
        [self.window.contentView addSubview:self.textOn];

        // Text Caps Off
        NSString *const textOffText = FORMAT(@"%@ ●", NSLocalizedString(@"Caps Lock Off", MK_CAPSLOCK_CATEGORY_STRING));
        self.textOff = [MKUI textViewWithText:textOffText frame:textRect];

        [self.textOff setTextColor:NSColor.darkGrayColor range:NSMakeRange(self.textOff.string.length - 1, 1)];
        [self.window.contentView addSubview:self.textOff];

        // Table Caps On
        self.tableOn = [[MKTableView alloc] initWithFrame:NSZeroRect];
        self.tableOn.delegate = self;

        [self.window.contentView addSubview:self.tableOn];

        // Table Caps Off
        self.tableOff = [[MKTableView alloc] initWithFrame:NSZeroRect];
        self.tableOff.delegate = self;

        [self.window.contentView addSubview:self.tableOff];

        // Done Button
        NSString *const doneButtonTitle = NSLocalizedString(@"Done", MK_CAPSLOCK_CATEGORY_STRING);
        self.doneButton = [MKUI buttonWithTitle:doneButtonTitle target:self action:@selector(onDone:) andRect:NSZeroRect];

        [self.doneButton sizeToFit];
        [self.window.contentView addSubview:self.doneButton];

        // Init
        [self sizeToFit];
        [self.window makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];
    }

    return self;
}


#pragma mark - MKTableViewDelegate

- (void)tableView:(MKTableView *)tableView didSelectRowAtIndex:(NSInteger)index {
    if (tableView == self.tableOn) {
        if (self.tableOff.selectedIndex == index) {
            [self.tableOff selectNextIndex];
        }
    }
    else if (self.tableOn.selectedIndex == index) {
        [self.tableOn selectNextIndex];
    }

    if ([self.delegate respondsToSelector:@selector(settingWindow:didSelectIndex:forCapsState:)]) {
        [self.delegate settingWindow:self didSelectIndex:index forCapsState:(tableView == self.tableOn)];
    }
}


#pragma mark - Private Methods

- (void)setCapsLayout:(nullable NSString *)layoutName forTable:(MKTableView *)table {
    if (!self.layouts || self.layouts.count < 2 || !layoutName) {
        return;
    }

    NSInteger index = -1;

    for (NSDictionary *const dict in self.layouts) {
        if ([dict[@"id"] isEqualToString:layoutName]) {
            index = [self.layouts indexOfObject:dict];

            break;
        }
    }

    if (index >= 0) {
        table.selectedIndex = index;
    }
}


#pragma mark - Getters & Setters

- (void)setLayouts:(nullable NSArray *)value {
    _layouts = value;

    self.tableOn.layouts = self.layouts;
    self.tableOff.layouts = self.layouts;
}


- (void)setCapsOnLayout:(nullable NSString *)layoutName {
    [self setCapsLayout:layoutName forTable:self.tableOn];
}


- (void)setCapsOffLayout:(nullable NSString *)layoutName {
    [self setCapsLayout:layoutName forTable:self.tableOff];
}


- (void)setUseCaps:(BOOL)value {
    self.checkbox.state = value ? 1 : 0;
    self.tableOn.enabled = value;
    self.tableOff.enabled = value;
}


- (BOOL)useCaps {
    return self.checkbox.state == 1;
}


#pragma mark - Actions

- (void)onDone:(NSButton *)sender {
    if ([self.delegate respondsToSelector:@selector(settingWindowWantsToClose:)]) {
        [self.delegate settingWindowWantsToClose:self];
    }
}


- (void)onUse:(NSButton *)sender {
    if ([self.delegate respondsToSelector:@selector(settingWindow:didSwitchUseState:)]) {
        [self.delegate settingWindow:self didSwitchUseState:self.useCaps];
    }

    self.useCaps = self.useCaps;
}


#pragma mark - NSView Stuff

- (void)sizeToFit {
    MK_WINDOW_SET_CENTER(self.window, WINDOW_WIDTH, WINDOW_HEIGHT);

    [self.checkbox sizeToFit];

    CGSize const chbxSize = self.checkbox.frame.size;
    CGFloat const chbxHeight = 56.0f;
    self.checkbox.frame = NSMakeRect(ceil((WINDOW_WIDTH - chbxSize.width) / 2.0f), BACK_HEIGHT - chbxSize.height - ceil((chbxHeight - chbxSize.height) / 2.0f), chbxSize.width, chbxSize.height);

    [self.textNote sizeToFit];

    CGSize const txtnSize = self.textNote.frame.size;
    self.textNote.frame = NSMakeRect(ceil((WINDOW_WIDTH - txtnSize.width) / 2.0f), self.checkbox.frame.origin.y - txtnSize.height - 10.0f, txtnSize.width, txtnSize.height);

    [self.textOn sizeToFit];

    self.textOn.frame = NSMakeRect(39.0f, 206.0f, self.textOn.frame.size.width, self.textOn.frame.size.height);

    [self.textOff sizeToFit];

    self.textOff.frame = NSMakeRect(270.0f, 206.0f, self.textOff.frame.size.width, self.textOff.frame.size.height);

    self.tableOn.frame = NSMakeRect(39.0f, 59.0f, 191.0f, 152.0f);
    self.tableOff.frame = NSMakeRect(270.0f, 59.0f, 191.0f, 152.0f);

    CGFloat const doneLeft = ceil((WINDOW_WIDTH - 90.0f) / 2.0f);
    self.doneButton.frame = NSMakeRect(doneLeft, 12.0f, 90.0f, self.doneButton.frame.size.height);
}


@end
