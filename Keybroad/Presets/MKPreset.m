//
//  MKPreset.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 06.02.13.
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




#import "MKPreset.h"
#import "MKLayout.h"
#import "MKSettings.h"
#import "MKCommon.h"




@interface MKPreset() {
    BOOL active;
    BOOL hidden;
}

@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSString * temp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDictionary * preset;
@property (nonatomic, retain) NSArray * rules;

@end




@implementation MKPreset


@synthesize active;


#pragma mark - init & dealloc

- (instancetype)initWithPresetName:(NSString *)name {
	if ((self = [super init])) {
		self.name = name;

        [self reload];
	}

	return self;
}


- (void)dealloc {
    self.name = nil;
    self.rules = nil;
    self.temp = nil;
    self.result = nil;
    self.preset = nil;

	[super	dealloc];
}


#pragma mark -

#define PRESET_FILENAME [NSBundle.mainBundle pathForResource:FORMAT(@"%@-preset", self.name) ofType:@"plist"]

- (void)reload {
	self.preset = [NSDictionary dictionaryWithContentsOfFile:PRESET_FILENAME];
	NSMutableArray * rules = NSMutableArray.array;
	active = [SETTINGS boolForKey:FORMAT(@"preset_%@", self.name)];
	
	for (NSDictionary * rule in self.preset[@"Rules"]) {
		NSError * error = NULL;
		NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:rule[@"Rule"] options:(rule[@"Case Sensitive"] && [rule[@"Case Sensitive"] integerValue] == 1) ? 0 : NSRegularExpressionCaseInsensitive error:&error];

		if (!error) {
			NSMutableDictionary * dict = NSMutableDictionary.dictionary;

            if (regex)
                dict[@"Regex"] = regex;
			
			if (rule[@"Layouts"])
                dict[@"Layouts"] = rule[@"Layouts"];
			
			if (rule[@"Transform"])
				dict[@"Transform"] = rule[@"Transform"];

			if (rule[@"Replacement"])
				dict[@"Replacement"] = rule[@"Replacement"];

			if (rule[@"FromLineStart"])
				dict[@"FromLineStart"] = rule[@"FromLineStart"];

			[rules addObject:dict];
		}
	}

    self.rules = [NSArray arrayWithArray:rules];
}


- (NSString *)description {
	return FORMAT(@"%@", self.preset);
}


- (BOOL)match:(NSArray *)layouts {
	if (!layouts)
		return NO;

	return [layouts indexOfObject:LAYOUT.currentLayout];
}


- (NSString *)apply:(NSString *)source fromStart:(BOOL)fromStart {
	self.result = source;

	for (NSDictionary * rule in self.rules) {
		if ([self match:rule[@"Layouts"]])
			continue;

		if ([rule[@"FromLineStart"] integerValue] == 1 && !fromStart)
			continue;

		NSRegularExpression * regex = rule[@"Regex"];
		self.result = [regex stringByReplacingMatchesInString:self.result options:0 range:NSMakeRange(0, self.result.length) withTemplate:rule[@"Replacement"]];
		NSString * transform = rule[@"Transform"];

		if (transform) {
			NSRange range = [regex rangeOfFirstMatchInString:self.result options:0 range:NSMakeRange(0, self.result.length)];

			if (range.length > 0 && range.location != NSNotFound) {
				self.temp = [self.result substringWithRange:range];

				if ([transform isEqualToString:@"uppercase"])
					self.temp = self.temp.uppercaseString;

				if ([transform isEqualToString:@"lowercase"])
					self.temp = self.temp.lowercaseString;

				self.result = [self.result stringByReplacingOccurrencesOfString:[self.result substringWithRange:range] withString:self.temp];
				self.temp = nil;
			}
		}
	}

	NSString * output = [[self.result copy] autorelease];
	self.result = nil;

	return output;
}


- (BOOL)check:(NSString *)source fromStart:(BOOL)fromStart {
	for (NSDictionary * rule in self.rules) {
		if ([self match:rule[@"Layouts"]])
			continue;
		
		if ([rule[@"FromLineStart"] integerValue] == 1 && !fromStart)
			continue;

		if ([rule[@"Regex"] numberOfMatchesInString:source options:0 range:NSMakeRange(0, source.length)] > 0)
			return YES;
	}

	return NO;
}


- (NSString *)title {
	return self.preset[@"Title"];
}


- (NSString *)group {
	return self.preset[@"Group"];
}


- (NSUInteger)order {
	return self.preset[@"Order"] ? [self.preset[@"Order"] integerValue] : NSUIntegerMax;
}


- (NSArray *)layouts {
    return IS_ARRAY_1(self.preset[@"Layouts"]) ? self.preset[@"Layouts"] : nil;
}


- (BOOL)hidden {
	return self.preset[@"Hidden"] ? ([self.preset[@"Hidden"] integerValue] == 1) : NO;
}


- (void)setActive:(BOOL)value {
	active = value;

	[SETTINGS setBool:active forKey:FORMAT(@"preset_%@", self.name)];
	[self reload];
}


@end
