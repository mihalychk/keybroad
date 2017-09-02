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




#import "MKSystemSettingsController.h"
#import "MKSystemSettingWindow.h"
#import "MKSettings.h"




@interface MKSystemSettingsController ()

@property (nonatomic, retain) MKSystemSettingWindow * window;

@end




@implementation MKSystemSettingsController


#pragma mark - init & dealloc

- (instancetype)init {
	if ((self = [super init])) {
		if (!MKSystemSettingsController.check) {
			NSUInteger major, minor, bugFix	= 0;
			
			[SETTINGS systemVersionMajor:&major minor:&minor bugFix:&bugFix];

			BOOL newFashion = (major == 10 && minor > 8);

			ProcessSerialNumber psn = { 0, kCurrentProcess };
			TransformProcessType(&psn, kProcessTransformToForegroundApplication);
			SetFrontProcess(&psn);

			self.window = [[MKSystemSettingWindow alloc] initWithNewStyle:newFashion andCallback:^(BOOL onSettings) {
                self.window = nil;

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


- (void)dealloc {
    self.window = nil;

	[super dealloc];
}


#pragma mark - Static Methods

+ (BOOL)check {
	return AXAPIEnabled();
}


@end
