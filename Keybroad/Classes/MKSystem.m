//
//  MKSystem.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 14.05.20.
//  Copyright © 2020 Mikhail Kalinin. All rights reserved.
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



#ifndef IOHIDManagerRef
#   import <IOKit/hid/IOHIDLib.h>
#endif
#import "MKCommon.h"
#import "MKHIDManager.h"
#import "MKSystem.h"



#define APPLICATION_PATH [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath]
#define CAPS_STRING @"<dict><key>HIDKeyboardModifierMappingDst</key><integer>-1</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>"



@implementation MKSystem


+ (BOOL)isApplicationStartingUp {
    Boolean foundIt = false;
    LSSharedFileListRef const loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *const currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];

        for (id const itemObject in currentLoginItems) {
            LSSharedFileListItemRef const item = (LSSharedFileListItemRef)itemObject;
            UInt32 const resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus const error = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);

            if (error == noErr) {
                foundIt = CFEqual(URL, APPLICATION_PATH);

                CFRelease(URL);

                if (foundIt) {
                    break;
                }
            }
        }

        CFRelease(loginItems);
    }

    return (BOOL)foundIt;
}


+ (void)enableApplicationStartUp:(BOOL)enabled {
    LSSharedFileListItemRef existingItem = NULL;
    LSSharedFileListRef const loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *const currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];

        for (id const itemObject in currentLoginItems) {
            LSSharedFileListItemRef const item = (LSSharedFileListItemRef)itemObject;
            UInt32 const resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus const error = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);

            if (error == noErr) {
                Boolean const foundIt = CFEqual(URL, APPLICATION_PATH);

                CFRelease(URL);

                if (foundIt) {
                    existingItem = item;

                    break;
                }
            }
        }

        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, NULL, NULL, (CFURLRef)APPLICATION_PATH, NULL, NULL);
        }
        else if (!enabled && (existingItem != NULL)) {
            LSSharedFileListItemRemove(loginItems, existingItem);
        }

        CFRelease(loginItems);
    }
}


+ (void)disableCapsLockStandardBehavior:(BOOL)disable {
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

        if (disable) {
            command = FORMAT(@"defaults -currentHost write -g com.apple.keyboard.modifiermapping.%@-%@-0 -array-add '%@'", vendorId, productId, CAPS_STRING);
        }
        else {
            command = FORMAT(@"defaults -currentHost delete -g com.apple.keyboard.modifiermapping.%@-%@-0", vendorId, productId);
        }

        system(command.UTF8String);
    }

    free(tIOHIDDeviceRefs);
    IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
    CFRelease(hidManager);
}


+ (void)osVersionMajor:(NSUInteger *)major minor:(NSUInteger *)minor bugFix:(NSUInteger *)bugFix {
    NSString *const versionString = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
    NSArray *const versions = [versionString componentsSeparatedByString:@"."];
    *major = 0;
    *minor = 0;
    *bugFix = 0;

    if (versions.count >= 1) {
        *major = [versions[0] integerValue];
    }

    if (versions.count >= 2) {
        *minor = [versions[1] integerValue];
    }

    if (versions.count >= 3) {
        *bugFix = [versions[1] integerValue];
    }
}


@end
