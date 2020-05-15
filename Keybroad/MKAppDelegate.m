//
//  MKAppDelegate.m
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



#import "MKAppDelegate.h"
#import "Keybroad.h"
#import "MKLayout.h"
#import "MKMenuController.h"
#import "MKPresetManager.h"
#import "MKSystemSettingsController.h"
#import "MKSharedApplication.h"
#import "MKSettings.h"
#import "MKSystem.h"



@interface MKAppDelegate () <MKSharedApplicationDelegate>

@property (nonatomic, nullable, strong) MKMenuController *controller;
@property (nonatomic, nullable, strong) Keybroad *keybroad;
@property (nonatomic, nullable, strong) MKSystemSettingsController *settingsController;

@end



@implementation MKAppDelegate


#pragma mark - MKSharedApplicationDelegate

- (void)sharedApplicationWasChangedFrontmostProcess {
    [self.keybroad onFrontmostAppChanged];
    [self.controller updateImages];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [MKLayout layout];

    if (!SETTINGS.wasInit) {
        SETTINGS.wasInit = YES;
        SETTINGS.active = YES;

        NSArray *const layouts = MKLayout.layout.layouts;

        if (layouts.count > 1) {
            SETTINGS.layoutForCapsOff = layouts[0][@"id"];
            SETTINGS.layoutForCapsOn = layouts[1][@"id"];
        }

        [SETTINGS setBool:YES forKey:@"preset_main"];
        [SETTINGS setBool:YES forKey:@"preset_autocapital"];
        [SETTINGS setBool:YES forKey:@"preset_typograph"];
        [SETTINGS setBool:YES forKey:@"preset_dbldots"];
    }

    PRESETS;
    SHARED_APP;
    SHARED_APP.delegate = self;

    [MKSystem enableApplicationStartUp:YES];

    if (!MKSystemSettingsController.check) {
        self.settingsController = [[MKSystemSettingsController alloc] init];

        return;
    }

    self.keybroad = [[Keybroad alloc] init];
    self.controller = [[MKMenuController alloc] init];
}


@end
