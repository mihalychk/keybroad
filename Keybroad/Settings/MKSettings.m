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
#import "MKHIDManager.h"
#import "MKCommon.h"




#define GET_BOOL(key)           [NSUserDefaults.standardUserDefaults boolForKey:key]
#define SET_BOOL(key,value)     [NSUserDefaults.standardUserDefaults setBool:value forKey:key]
#define GET_OBJ(key)            [NSUserDefaults.standardUserDefaults objectForKey:key]
#define SET_OBJ(key,value)      [NSUserDefaults.standardUserDefaults setObject:value forKey:key]
#define SAVE()                  [NSUserDefaults.standardUserDefaults synchronize]
#define APPLICATION_PATH        [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath]
#define CAPS_STRING             @"<dict><key>HIDKeyboardModifierMappingDst</key><integer>-1</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>"




@interface MKSettings()

@property (nonatomic, retain) NSMutableArray *excludedApps;

@end




@implementation MKSettings


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init])) {
        NSArray *const settings = GET_OBJ(@"excluded");

        if (IS_ARRAY_1(settings)) {
            self.excludedApps = [NSMutableArray arrayWithArray:settings];
        }
        else {
            NSString * path = [NSBundle.mainBundle pathForResource:@"excluded" ofType:@"plist"];
            self.excludedApps = [[[NSMutableArray alloc] initWithContentsOfFile:path] autorelease];

            SET_OBJ(@"excluded", self.excludedApps);
            SAVE();
        }
    }

    return self;
}


- (void)dealloc {
    self.excludedApps = nil;

    [super dealloc];
}


#pragma mark - Properties

-(void)setActive:(BOOL)value {
    SET_BOOL(@"active", value);
    SAVE();
}


-(BOOL)active {
    return GET_BOOL(@"active");
}


-(void)setUseCaps:(BOOL)value {
    SET_BOOL(@"useCaps", value);
    SAVE();

    IOHIDManagerRef const hidManager = MKHIDManager.hidManager;

    IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);

    CFSetRef const deviceCFSetRef = IOHIDManagerCopyDevices(hidManager);
    CFIndex const deviceCount = CFSetGetCount(deviceCFSetRef);
    IOHIDDeviceRef *const tIOHIDDeviceRefs = malloc(sizeof(IOHIDDeviceRef) * deviceCount);

    CFSetGetValues(deviceCFSetRef, (const void **)tIOHIDDeviceRefs);
    CFRelease(deviceCFSetRef);

    for (CFIndex deviceIndex = 0; deviceIndex < deviceCount; deviceIndex++) {
        if (!IOHIDDeviceConformsTo(tIOHIDDeviceRefs[deviceIndex], kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard)) {
            continue;
        }

        NSNumber *const vendorId = (__bridge NSNumber *)IOHIDDeviceGetProperty(tIOHIDDeviceRefs[deviceIndex], CFSTR(kIOHIDVendorIDKey));
        NSNumber *const productId = (__bridge NSNumber *)IOHIDDeviceGetProperty(tIOHIDDeviceRefs[deviceIndex], CFSTR(kIOHIDProductIDKey));

        NSString *command = nil;

        if (value)
            command = FORMAT(@"defaults -currentHost write -g com.apple.keyboard.modifiermapping.%@-%@-0 -array-add '%@'", vendorId, productId, CAPS_STRING);

        else
            command = FORMAT(@"defaults -currentHost delete -g com.apple.keyboard.modifiermapping.%@-%@-0", vendorId, productId);

        //NSLog(@"command: %@", command);
        system(command.UTF8String);
    }

    free(tIOHIDDeviceRefs);
    IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
    CFRelease(hidManager);
}


-(BOOL)useCaps {
    return GET_BOOL(@"useCaps");
}


- (void)setLayoutForCapsOn:(NSString *)value {
    SET_OBJ(@"layoutForCapsOn", value);
    SAVE();
}


- (NSString *)layoutForCapsOn {
    return GET_OBJ(@"layoutForCapsOn");
}


- (void)setLayoutForCapsOff:(NSString *)value {
    SET_OBJ(@"layoutForCapsOff", value);
    SAVE();
}


- (NSString *)layoutForCapsOff {
    return GET_OBJ(@"layoutForCapsOff");
}


-(void)setWasInit:(BOOL)value {
    SET_BOOL(@"wasInit", value);
    SAVE();
}


-(BOOL)wasInit {
    return GET_BOOL(@"wasInit");
}


- (BOOL)startup {
    Boolean foundIt = false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (loginItems) {
        UInt32 seed = 0U;
        NSArray * currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];

        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);

            if (err == noErr) {
                foundIt = CFEqual(URL, APPLICATION_PATH);

                CFRelease(URL);
                
                if (foundIt)
                    break;

            }
        }
        CFRelease(loginItems);
    }

    return (BOOL)foundIt;
}


- (void)setStartup:(BOOL)enabled {
    LSSharedFileListItemRef existingItem = NULL;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (loginItems) {
        UInt32 seed = 0U;
        NSArray * currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];

        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);

            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, APPLICATION_PATH);

                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;

                    break;
                }
            }
        }

        if (enabled && (existingItem == NULL))
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (CFURLRef)APPLICATION_PATH, NULL, NULL);

        else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);

        CFRelease(loginItems);
    }
}


#pragma mark - Public Methods

- (void)systemVersionMajor:(NSUInteger *)major minor:(NSUInteger *)minor bugFix:(NSUInteger *)bugFix {
    NSString * versionString = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
    NSArray * versions = [versionString componentsSeparatedByString:@"."];
    *major = 0;
    *minor = 0;
    *bugFix = 0;

    if (versions.count >= 1)
        *major = [versions[0] integerValue];

    if (versions.count >= 2)
        *minor = [versions[1] integerValue];

    if (versions.count >= 3)
        *bugFix = [versions[1] integerValue];
}


- (MKSettingsInterfaceType)currentInterfaceType {
    NSString * value = [NSUserDefaults.standardUserDefaults stringForKey:@"AppleInterfaceStyle"];

    if (!IS_STRING_1(value))
        return MKSettingsInterfaceTypeLight;

    if ([value.lowercaseString isEqualToString:@"dark"])
        return MKSettingsInterfaceTypeDark;

    return MKSettingsInterfaceTypeUnknown;
}


- (void)setBool:(BOOL)value forKey:(NSString *)key {
    SET_BOOL(key, value);
    SAVE();
}


- (BOOL)boolForKey:(NSString *)key {
    return GET_BOOL(key);
}


- (void)addExcludeApp:(NSString *)bundleId {
    if (!bundleId || bundleId.length < 1)
        return;

    if ([self.excludedApps indexOfObject:bundleId] != NSNotFound)
        return;

    [self.excludedApps addObject:bundleId];

    SET_OBJ(@"excluded", self.excludedApps);
    SAVE();
}


- (void)removeExcludeApp:(NSString *)bundleId {
    if (!bundleId || bundleId.length < 1)
        return;

    if ([self.excludedApps indexOfObject:bundleId] == NSNotFound)
        return;

    [self.excludedApps removeObject:bundleId];

    SET_OBJ(@"excluded", self.excludedApps);
    SAVE();
}


- (BOOL)isExcluded:(NSString *)bundleId {
    return [self.excludedApps indexOfObject:bundleId] != NSNotFound;
}


#pragma mark - Singleton

+ (instancetype)sharedSettings {
    static MKSettings * settings = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        settings = [[MKSettings alloc] init];
    });

    return settings;
}


@end
