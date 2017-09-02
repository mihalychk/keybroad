//
//  MKPresetManager.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 26.02.13.
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




#import "MKPresetManager.h"
#import "MKLayout.h"




@interface MKPresetManager()

@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSArray * presets;

- (void)loadPresets;

@end



@implementation MKPresetManager


@synthesize result;


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init]))
        [self loadPresets];

    return self;
}


- (void)dealloc {
    self.presets = nil;
    self.result = nil;

    [super dealloc];
}


#pragma mark - Private Methods

- (void)loadPresets {
    NSMutableArray * array = NSMutableArray.array;

	NSArray * dirFiles = [NSFileManager.defaultManager contentsOfDirectoryAtPath:NSBundle.mainBundle.resourcePath error:nil];
	NSArray * list = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '-preset.plist'"]];

	for (NSString * path in list) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

		MKPreset * preset = [[[MKPreset alloc] initWithPresetName:[path stringByReplacingOccurrencesOfString:@"-preset.plist" withString:@""]] autorelease];
		
		if (preset && [LAYOUT matchLayouts:preset.layouts])
			[array addObject:preset];

		[pool drain];
	}

	[array sortUsingComparator:^NSComparisonResult(id a, id b) {
		NSUInteger first = ((MKPreset *)a).order;
		NSUInteger second = ((MKPreset *)b).order;

		return first < second ? NSOrderedAscending : (first == second ? NSOrderedSame : NSOrderedDescending);
	}];

    self.presets = [NSArray arrayWithArray:array];
}


#pragma mark - Public Methods

- (BOOL)check:(NSString *)source fromStart:(BOOL)fromStart {
	for (MKPreset * preset in self.presets)
		if (preset.active && [preset check:source fromStart:fromStart])
			return YES;

	return NO;
}


- (NSString *)apply:(NSString *)source fromStart:(BOOL)fromStart {
	self.result = source;
	
	for (MKPreset * preset in self.presets)
		if (preset.active)
			self.result = [preset apply:result fromStart:fromStart];
	
	NSString * res = [[result retain] autorelease];
	self.result = nil;
	
	return res;
}


#pragma mark - Singleton

+ (instancetype)sharedManager {
    static MKPresetManager * sharedManager = nil;
	static dispatch_once_t pred;
	
	dispatch_once(&pred, ^{
		sharedManager = [[MKPresetManager alloc] init];
	});

	return sharedManager;
}


@end
