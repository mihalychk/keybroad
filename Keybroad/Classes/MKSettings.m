//
//  MKSettings.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 31.03.13.
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



#import <ServiceManagement/ServiceManagement.h>
#import "MKSettings.h"
#import "MKSystem.h"
#import "MKHIDManager.h"
#import "MKCommon.h"



@interface MKSettings()

@property (nonatomic, strong) NSMutableArray *excludedApps;

@end



@implementation MKSettings


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init])) {
        NSArray *const settings = [self objectForKey:@"excluded"];

        if (IS_ARRAY_1(settings)) {
            self.excludedApps = [NSMutableArray arrayWithArray:settings];
        }
        else {
            NSString *const path = [NSBundle.mainBundle pathForResource:@"excluded" ofType:@"plist"];
            self.excludedApps = [[NSMutableArray alloc] initWithContentsOfFile:path];

            [self saveObject:self.excludedApps forKey:@"excluded"];
        }
    }

    return self;
}


#pragma mark - Properties

-(void)setActive:(BOOL)value {
    [self saveBool:value forKey:@"active"];
}


-(BOOL)active {
    return [self boolForKey:@"active"];
}


-(void)setUseCaps:(BOOL)value {
    [self saveBool:value forKey:@"useCaps"];

    [MKSystem disableCapsLockStandardBehavior:value];
}


-(BOOL)useCaps {
    return [self boolForKey:@"useCaps"];
}


- (void)setLayoutForCapsOn:(NSString *)value {
    [self saveObject:value forKey:@"layoutForCapsOn"];
}


- (NSString *)layoutForCapsOn {
    return [self objectForKey:@"layoutForCapsOn"];
}


- (void)setLayoutForCapsOff:(NSString *)value {
    [self saveObject:value forKey:@"layoutForCapsOff"];
}


- (NSString *)layoutForCapsOff {
    return [self objectForKey:@"layoutForCapsOff"];
}


-(void)setWasInit:(BOOL)value {
    [self saveBool:value forKey:@"wasInit"];
}


-(BOOL)wasInit {
    return [self boolForKey:@"wasInit"];
}


#pragma mark - Excluded App

- (void)addExcludedApp:(NSString *)bundleId {
    if (!bundleId || bundleId.length < 1)
        return;

    if ([self.excludedApps indexOfObject:bundleId] != NSNotFound) {
        return;
    }

    [self.excludedApps addObject:bundleId];
    [self saveObject:self.excludedApps forKey:@"excluded"];
}


- (void)removeExcludedApp:(NSString *)bundleId {
    if (![self isExcluded:bundleId]) {
        return;
    }

    [self.excludedApps removeObject:bundleId];
    [self saveObject:self.excludedApps forKey:@"excluded"];
}


- (BOOL)isExcluded:(NSString *)bundleId {
    if (!bundleId || bundleId.length < 1) {
        return NO;
    }

    return [self.excludedApps indexOfObject:bundleId] != NSNotFound;
}


#pragma mark - Common Public

- (nullable id)objectForKey:(NSString *)key {
    NSParameterAssert(key);

    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}


- (void)setObject:(nullable id)object forKey:(NSString *)key {
    NSParameterAssert(key);

    if (object) {
        [NSUserDefaults.standardUserDefaults setObject:object forKey:key];
    }
    else {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
    }
}


- (void)saveObject:(nullable id)object forKey:(NSString *)key {
    [self setObject:object forKey:key];
    [self saveSettings];
}


- (BOOL)boolForKey:(NSString *)key {
    NSParameterAssert(key);

    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}


- (void)setBool:(BOOL)value forKey:(NSString *)key {
    NSParameterAssert(key);

    [NSUserDefaults.standardUserDefaults setBool:value forKey:key];
}


- (void)saveBool:(BOOL)value forKey:(NSString *)key {
    [self setBool:value forKey:key];
    [self saveSettings];
}


- (void)saveSettings {
    [NSUserDefaults.standardUserDefaults synchronize];
}


#pragma mark - Singleton

+ (instancetype)sharedSettings {
    static MKSettings *settings = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        settings = [[MKSettings alloc] init];
    });

    return settings;
}


@end
