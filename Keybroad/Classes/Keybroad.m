//
//  Keybroad.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 03.02.13.
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



#import <Carbon/Carbon.h>
#import "Keybroad.h"
#import "MKCommon.h"
#import "MKHIDManager.h"
#import "MKLayout.h"
#import "MKKeyStore.h"
#import "MKPreset.h"
#import "MKPresetManager.h"
#import "MKSettings.h"
#import "MKSystemSettingsController.h"
#import "MKSharedApplication.h"



#define SYMBOLS_IN_STORE 10



@interface Keybroad() <MKHIDManagerDelegate, MKLayoutDelegate> {
    NSInteger lastProcessId;
    id keyboardHandler;
    id mouseHandler;
    BOOL isProcess;
}

- (void)handleEvent:(NSEvent *)event;
- (BOOL)validSymbol:(NSString *)symbol;
- (BOOL)stopSymbol:(UniChar)symbol;
- (void)doKeyboard:(BOOL)fromStart;

@property (nonatomic, retain) id keyboardHandler;
@property (nonatomic, retain) id mouseHandler;
@property (nonatomic, retain) MKHIDManager * hidManager;

@end



@implementation Keybroad


@synthesize keyboardHandler, mouseHandler;


#pragma mark- init & dealloc

- (instancetype)init {
    if ((self = [super init])) {
        self.hidManager = [[[MKHIDManager alloc] init] autorelease];
        self.hidManager.delegate = self;
        lastProcessId = -1;
        isProcess = NO;

        self.keyboardHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyDownMask) handler:^(NSEvent * event){
            [self handleEvent:event];
        }];

        self.mouseHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSEventMask)NSLeftMouseUp handler:^(NSEvent * event) {
            if (SETTINGS.active) {
                [KEYSTORE invalidate];
            }
        }];

        MKLayout.layout.delegate = self;

        [self updateCaps];
    }

    return self;
}


- (void)dealloc {
    MKLayout.layout.delegate = nil;

    self.hidManager.delegate = nil;
    self.hidManager = nil;

    [NSEvent removeMonitor:keyboardHandler];
    [NSEvent removeMonitor:mouseHandler];
    [keyboardHandler release];
    [super dealloc];
}


#pragma mark - Caps

- (void)updateCaps {
    self.hidManager.capsState = SETTINGS.useCapsToIndicate && [SETTINGS.layoutForCapsOn isEqualToString:MKLayout.layout.currentLayoutId];
}


#pragma mark - Public Methods

- (void)sendKeyCode:(NSInteger)keycode withModifiers:(UInt32)modifiers {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, true);

    CGEventSetFlags(event, modifiers);
    CGEventPost(kCGSessionEventTap, event);
    CFRelease(event);

    event = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, false);

    CGEventSetFlags(event, modifiers);
    CGEventPost(kCGSessionEventTap, event);
    CFRelease(event);
}


- (void)sendText:(UniChar *)text length:(NSUInteger)length {
    CGEventRef const event = CGEventCreateKeyboardEvent(NULL, 0, true);

    CGEventKeyboardSetUnicodeString(event, length, text);
    CGEventPost(kCGSessionEventTap, event);
    CFRelease(event);
}


- (void)backspace:(NSUInteger)count {
    for (int i = 0; i < count; i++) {
        [self sendKeyCode:51 withModifiers:0];
    }
}


#pragma mark - Public Methods

- (void)typoSelectedText {
    NSString *const before = [SHARED_APP frontmostTopElementText:YES];

    if (!before || before.length < 1) {
        return;
    }

    NSString *const after = [PRESETS apply:before fromStart:NO];

    if (!after || after.length < 1) {
        return;
    }

    NSUInteger const aLength = after.length;

    UniChar chars[aLength];
    memset(chars, 0, sizeof(chars));

    [after getBytes:chars maxLength:(aLength * sizeof(UniChar)) usedLength:NULL encoding:NSUTF16StringEncoding options:0 range:NSMakeRange(0, aLength) remainingRange:NULL];
    [self backspace:1];

    NSUInteger const step = 16;
    NSUInteger const steps = (aLength / step);
    NSUInteger const rest = aLength - (steps * step);
    int i = 0;

    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25f, NO);

    for (; i < aLength - rest; i += step) {
        [self sendText:&chars[i] length:step];
    }

    if (rest > 0) {
        [self sendText:&chars[i] length:rest];
    }
}


- (void)onFrontmostAppChanged {
    [self updateCaps];

    ASYNCH_MAINTHREAD_AFTER(0.125f, ^{
        [self updateCaps];
    });

    ASYNCH_MAINTHREAD_AFTER(0.25f, ^{
        [self updateCaps];
    });

    ASYNCH_MAINTHREAD_AFTER(0.5f, ^{
        [self updateCaps];
    });
}


#pragma mark - Private Methods

- (BOOL)validSymbol:(NSString *)symbol {
    UniChar ch = [symbol characterAtIndex:0];

    switch (ch) {
        case 0x20:                        //  
        case 0x2E:                        // .
        case 0x3A:                        // :
        case 0x3B:                        // ;
        case 0x2C:                        // ,
        case 0x21:                        // !
        case 0x3F:                        // ?
            return NO;
            
        default:
            break;
    }

    return YES;
}


- (BOOL)stopSymbol:(UniChar)symbol {
    switch (symbol) {
        //case 0x7F:                    // Backspace
        case 0xF728:                    // Delete
        case 0x09:                      // Tab
        case 0xF700:                    // ↑
        case 0xF701:                    // ↓
        case 0xF702:                    // ←
        case 0xF703:                    // →
        case 0xF729:                    // Home
        case 0xF72B:                    // End
        case 0xF72C:                    // Page Down
        case 0xF72D:                    // Page Up
        //case 0x0D:                    // Enter
        case 0x1B:                      // Escape
            return NO;

        default:
            break;
    }

    return YES;
}


#pragma mark - MKHIDManagerDelegate

- (void)hidManagerDidPressCapsLock:(MKHIDManager *)hidManager {
    if (SETTINGS.useCapsToSwitch) {
        BOOL const currentCapsState = [MKLayout.layout.currentLayoutId isEqualToString:SETTINGS.layoutForCapsOn];
        BOOL const capsState = !currentCapsState;

        NSString *const newLayoutId = capsState ? SETTINGS.layoutForCapsOn : SETTINGS.layoutForCapsOff;

        [MKLayout.layout setLayout:newLayoutId];

        self.hidManager.capsState = capsState;
    }
}


#pragma mark - MKLayoutDelegate

- (void)layoutDidChange {
    [self updateCaps];
}


#pragma mark - Event Handler

- (void)handleEvent:(NSEvent *)event {
    if (!SETTINGS.active || [SETTINGS isExcluded:SHARED_APP.frontmostProcessBundleID]) {
        return;
    }

    @synchronized (self) {
        NSInteger const processId = SHARED_APP.frontmostProcessID;
        UniChar const ch = [event.characters characterAtIndex:0];
        NSUInteger const modifiers = [event modifierFlags];
        BOOL const fromStart = (ch == 0x0D);

        if (fromStart) {
            [KEYSTORE invalidate];
        }

        if (modifiers & NX_COMMANDMASK && modifiers & NX_CONTROLMASK && event.keyCode == 17) {// Cmd + Ctrl + T
            [self typoSelectedText];

            return;
        }

        if (processId != 0 && processId == lastProcessId) {
            if (modifiers & NX_COMMANDMASK) {
                [KEYSTORE invalidate];
            }
            else if (ch == 0x7F) {
                if (modifiers & NX_ALTERNATEMASK) {
                    [KEYSTORE invalidate];
                }
                else {
                    [KEYSTORE backspace];
                }
            }
            else if ([self stopSymbol:ch]) {
                [KEYSTORE addSymbol:event.characters];
                [self doKeyboard:fromStart];
            }
            else {
                [KEYSTORE invalidate];
            }
        }
        else {
            [KEYSTORE invalidate];
        }

        lastProcessId = processId;
    }
}


- (void)doKeyboard:(BOOL)fromStart {
    if (isProcess) {
        return;
    }

    isProcess = YES;
    NSString *before = [KEYSTORE symbols:SYMBOLS_IN_STORE];

    if (![PRESETS check:before fromStart:fromStart]) {
        isProcess = NO;

        return;
    }

    NSString *after = [PRESETS apply:before fromStart:fromStart];

    if ([before isEqualToString:after] || (before.length < 1 || after.length < 1)) {
        isProcess = NO;

        return;
    }

    while (before.length > 0 && after.length > 0 && [before characterAtIndex:0] == [after characterAtIndex:0]) {
        before = [before substringFromIndex:1];
        after = [after substringFromIndex:1];
    }

    NSUInteger const aLength = after.length;

    [self backspace:before.length];
    [KEYSTORE invalidate];

    UniChar chars[aLength];

    [after getBytes:chars maxLength:(aLength * sizeof(UniChar)) usedLength:NULL encoding:NSUTF16StringEncoding options:0 range:NSMakeRange(0, aLength) remainingRange:NULL];
    [self sendText:chars length:aLength];

    for (int i = 0; i < aLength; i++) {
        [KEYSTORE addSymbol:[after substringWithRange:NSMakeRange(i, 1)]];
    }

    for (int i = 0; i < before.length; i++) {
        [KEYSTORE addSymbol:@"~"];
    }

    isProcess = NO;
}


@end
