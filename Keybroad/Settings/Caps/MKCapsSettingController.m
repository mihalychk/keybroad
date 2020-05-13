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
#import "MKLayout.h"
#import "MKSettings.h"



@interface MKCapsSettingController () <MKCapsSettingWindowDelegate>

@property (nonatomic, nullable, copy) MKCapsSettingCallback complete;
@property (nonatomic, nullable, retain) MKCapsSettingWindow *window;

@end



@implementation MKCapsSettingController


#pragma mark - init & dealloc

- (instancetype)initWithCallback:(nullable MKCapsSettingCallback)callback {
    if ((self = [super init])) {
        self.complete = callback;

        WEAKIFY(self);

        self.window = [[MKCapsSettingWindow alloc] initWithCallback:^{
            selfWeakified.window = nil;

            if (selfWeakified.complete)
                selfWeakified.complete();
        }];

        self.window.layouts = MKLayout.layout.layouts;
        self.window.useCaps = SETTINGS.useCaps;

        [self.window setCapsOnLayout:SETTINGS.layoutForCapsOn];
        [self.window setCapsOffLayout:SETTINGS.layoutForCapsOff];

        self.window.delegate = self;     // IMPORTANT!!!
    }

    return self;
}


- (void)dealloc {
    self.complete = nil;
    self.window = nil;

    [super dealloc];
}


#pragma mark -

- (void)settingWindow:(MKCapsSettingWindow *)window didSwitchUseState:(BOOL)state {
    SETTINGS.useCaps = state;
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


@end