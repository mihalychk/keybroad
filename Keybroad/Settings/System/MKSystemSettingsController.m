//
//  MKSystemSettingsController.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 21.04.13.
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
#import "MKSystemSettingsController.h"
#import "MKSystemSettingsWindow.h"
#import "MKSettings.h"
#import "MKSystem.h"



@interface MKSystemSettingsController ()

@property (nonatomic, nullable, strong) MKSystemSettingsWindow *window;

@end



@implementation MKSystemSettingsController


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init])) {
        if (!MKSystemSettingsController.check) {
            NSUInteger major, minor, bugFix = 0;

            [MKSystem osVersionMajor:&major minor:&minor bugFix:&bugFix];

            BOOL const newFashion = (major == 10 && minor > 8);

            ProcessSerialNumber psn = { 0, kCurrentProcess };
            TransformProcessType(&psn, kProcessTransformToForegroundApplication);
            SetFrontProcess(&psn);

            WEAKIFY(self);

            self.window = [[MKSystemSettingsWindow alloc] initWithNewStyle:newFashion andCallback:^(BOOL onSettings) {
                selfWeakified.window = nil;

                if (onSettings) {
                    NSLog(@"System Preferences");

                    if (newFashion)
                        [NSWorkspace.sharedWorkspace openFile:@"/System/Library/PreferencePanes/Security.prefPane"];

                    else
                        [NSWorkspace.sharedWorkspace openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
                }

                [NSApplication.sharedApplication terminate:nil];
            }];
        }
    }

    return self;
}


#pragma mark - Static Methods

+ (BOOL)check {
    return AXAPIEnabled();
}


@end
