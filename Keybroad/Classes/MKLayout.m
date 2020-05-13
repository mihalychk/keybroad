//
//  MKLayout.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 03.04.13.
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




#import <Carbon/Carbon.h>
#import "MKCommon.h"
#import "MKLayout.h"




@interface MKLayout() {
    CFNotificationCenterRef center;
    BOOL capsLockPressed;
}

@property (nonatomic, retain) NSMutableSet * layoutsSet;

- (void)subInit;
- (void)deInit;
- (void)onLayoutChange;

@end




@implementation MKLayout


#pragma mark - Helpers

- (NSString *)currentLayoutName {
    TISInputSourceRef sourceRef = TISCopyCurrentKeyboardInputSource();
    NSString * result = [NSString stringWithString:(NSString *)TISGetInputSourceProperty(sourceRef, kTISPropertyLocalizedName)];

    // I don't know why the fuck it is leaking here

    CFRelease(sourceRef);

    return result;
}


- (NSString *)currentLayoutId {
    TISInputSourceRef sourceRef = TISCopyCurrentKeyboardInputSource();
    NSString * result = [NSString stringWithString:TISGetInputSourceProperty(sourceRef, kTISPropertyInputSourceID)];

    // I don't know why the fuck it is leaking here

    CFRelease(sourceRef);

    return result;
}


- (NSString *)currentLayout {
    TISInputSourceRef sourceRef = TISCopyCurrentKeyboardInputSource();
    NSString * result = [NSString stringWithString:(NSString *)[(NSArray *)TISGetInputSourceProperty(sourceRef, kTISPropertyInputSourceLanguages) objectAtIndex:0]];

    // I don't know why the fuck it is leaking here

    CFRelease(sourceRef);

    return result;
}


- (NSArray *)sourceList {
    CFArrayRef source = TISCreateInputSourceList(NULL, false);
    NSArray * list = [NSArray arrayWithArray:(NSArray *)source];

    CFRelease(source);

    return list;
}


- (BOOL)matchLayouts:(NSArray *)layouts {
    if (!IS_ARRAY_1(layouts))  // If no layout specified, rule works for any layout
        return YES;

    for (NSString * layout in layouts)
        if (IS_STRING_1(layout) && [self.layoutsSet containsObject:layout.lowercaseString])
            return YES;

    return NO;
}


#pragma mark - subinit & deinit

- (void)subInit {
    self.layoutsSet = NSMutableSet.set;
    NSArray * sourceArray = self.sourceList;

    for (int i = 0; i < sourceArray.count; i++) {
        TISInputSourceRef ref = (TISInputSourceRef)sourceArray[i];
        NSString * layoutType = TISGetInputSourceProperty(ref, kTISPropertyInputSourceType);

        if ([layoutType isEqualToString:@"TISTypeKeyboardLayout"]) {
            NSArray<NSString *> * layout = TISGetInputSourceProperty(ref, kTISPropertyInputSourceLanguages);

            if (IS_ARRAY_1(layout) && IS_STRING_1(layout[0]))
                [self.layoutsSet addObject:[NSString stringWithString:layout[0].lowercaseString]];
        }
    }

    center = CFNotificationCenterGetDistributedCenter();

    if (center) {
        CFNotificationCenterAddObserver(center, self, onLayoutChange, kTISNotifySelectedKeyboardInputSourceChanged, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, self, onLayoutsCountChange, kTISNotifyEnabledKeyboardInputSourcesChanged, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}


- (void)deInit {
    if (center) {
        CFNotificationCenterRemoveObserver(center, self, kTISNotifySelectedKeyboardInputSourceChanged, NULL);
        CFNotificationCenterRemoveObserver(center, self, kTISNotifyEnabledKeyboardInputSourcesChanged, NULL);

        center = nil;
    }

    self.layoutsSet = nil;
}


#pragma mark - dealloc

- (void)dealloc {
    self.delegate = nil;

    [self deInit];
    [super dealloc];
}


#pragma mark -

- (NSArray *)layouts {
    NSMutableArray * layoutsArray = NSMutableArray.array;
    NSArray * sourceArray = self.sourceList;

    for (int i = 0; i < sourceArray.count; i++) {
        TISInputSourceRef ref = (TISInputSourceRef)sourceArray[i];
        NSString * layoutType = TISGetInputSourceProperty(ref, kTISPropertyInputSourceType);

        if ([layoutType isEqualToString:@"TISTypeKeyboardLayout"]) {
            NSString * layoutName = TISGetInputSourceProperty(ref, kTISPropertyLocalizedName);
            NSString * layoutId = TISGetInputSourceProperty(ref, kTISPropertyInputSourceID);
            NSImage * layoutImage = [[[NSImage alloc] initWithIconRef:TISGetInputSourceProperty(ref, kTISPropertyIconRef)] autorelease];

            for (NSImageRep * rep in layoutImage.representations)
                if (rep.size.width > 16)
                    [layoutImage removeRepresentation:rep];

            [layoutsArray addObject:@{@"id": layoutId, @"title": layoutName, @"image": layoutImage}];
        }

        [layoutType release];
    }

    return layoutsArray;
}


- (void)setLayout:(NSString *)targetLayoutId {
    capsLockPressed = YES;

    NSArray * sourceArray = self.sourceList;

    for (NSUInteger i = 0; i < sourceArray.count; i++) {
        TISInputSourceRef ref = (TISInputSourceRef)sourceArray[i];

        NSString * layoutType = TISGetInputSourceProperty(ref, kTISPropertyInputSourceType);

        if ([layoutType isEqualToString:@"TISTypeKeyboardLayout"]) {
            NSString * layoutId = TISGetInputSourceProperty(ref, kTISPropertyInputSourceID);

            if ([layoutId isEqualToString:targetLayoutId]) {
                TISSelectInputSource(ref);

                break;
            }
        }
    }
}


- (void)onLayoutChange {
    if (!capsLockPressed) {
        if ([self.delegate respondsToSelector:@selector(layoutDidChange)])
            [self.delegate layoutDidChange];
    }

    capsLockPressed = NO;
}


#pragma mark -

void onLayoutChange(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    MKLayout * layout = (MKLayout *)observer;

    [layout onLayoutChange];
}


void onLayoutsCountChange(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    MKLayout * layout = (MKLayout *)observer;

    [layout deInit];
    [layout subInit];
}


#pragma mark - Singleton

+ (instancetype)layout {
    static MKLayout *layout = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        layout = [[MKLayout alloc] init];

        [layout subInit];
    });

    return layout;
}


@end
