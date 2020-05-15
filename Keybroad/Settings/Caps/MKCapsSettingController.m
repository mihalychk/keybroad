//
//  MKCapsSettingController.m
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



#import "MKCommon.h"
#import "MKCapsSettingController.h"
#import "MKCapsSettingWindow.h"
#import "MKLayout.h"
#import "MKSettings.h"



@interface MKCapsSettingController () <NSWindowDelegate, MKCapsSettingWindowDelegate>

@property (nonatomic, nullable, copy) MKCapsSettingCallback complete;
@property (nonatomic, nullable, strong) MKCapsSettingWindow *window;

@end



@implementation MKCapsSettingController


#pragma mark - init & dealloc

- (instancetype)initWithCallback:(nullable MKCapsSettingCallback)callback {
    if ((self = [super init])) {
        self.complete = callback;

        self.window = [[MKCapsSettingWindow alloc] init];
        self.window.layouts = MKLayout.layout.layouts;
        self.window.capsOffLayout = SETTINGS.layoutForCapsOff;
        self.window.capsOnLayout = SETTINGS.layoutForCapsOn;
        self.window.delegate = self;
        self.window.useCapsToIndicate = SETTINGS.useCapsToIndicate;
        self.window.useCapsToSwitch = SETTINGS.useCapsToSwitch;

        self.window.window.delegate = self;
    }

    return self;
}


#pragma mark -

- (void)settingWindow:(MKCapsSettingWindow *)window didUpdateCapsIndicateState:(BOOL)state {
    SETTINGS.useCapsToIndicate = state;
}


- (void)settingWindow:(MKCapsSettingWindow *)window didUpdateCapsSwitchState:(BOOL)state {
    SETTINGS.useCapsToSwitch = state;
}


- (void)settingWindow:(MKCapsSettingWindow *)window didSelectIndex:(NSInteger)index forCapsState:(BOOL)state {
    NSString *const value = self.window.layouts[index][@"id"];

    if (state) {
        SETTINGS.layoutForCapsOn = value;
    }
    else {
        SETTINGS.layoutForCapsOff = value;
    }
}


- (void)settingWindowWantsToClose:(MKCapsSettingWindow *)window {
    [window.window close];
}


#pragma mark -

- (void)windowWillClose:(NSNotification *)notification {
    WEAKIFY(self);

    ASYNCH_MAINTHREAD(^{
        if (selfWeakified.complete) {
            selfWeakified.complete();
        }
    });
}


@end
