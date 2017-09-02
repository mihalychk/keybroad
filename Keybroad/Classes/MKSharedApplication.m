//
//  MKSharedApplication.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 01.11.13.
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




#import "MKSharedApplication.h"
#import "MKCommon.h"




@implementation MKSharedApplication


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init]))
        [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(onWorkspaceNotification:) name:NSWorkspaceDidActivateApplicationNotification object:nil];

    return self;
}


- (void)dealloc {
    self.delegate = nil;

    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];

    [super dealloc];
}


#pragma mark - Private Methods

- (void)onWorkspaceNotification:(NSNotification *)notification {
    ASYNCH_MAINTHREAD(^{
        if ([self.delegate respondsToSelector:@selector(sharedApplicationWasChangedFrontmostProcess)])
            [self.delegate sharedApplicationWasChangedFrontmostProcess];
    });
}


#pragma mark - Public Methods

- (NSString *)frontmostProcessBundleID {
    return NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier;
}


- (pid_t)frontmostProcessID {
    return NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier;
}


- (AXUIElementRef)frontmostTopElement:(AXError *)error {
    pid_t processId = SHARED_APP.frontmostProcessID;
    AXUIElementRef windowRef = AXUIElementCreateApplication(processId);
    AXUIElementRef elementRef = nil;

    *error = AXUIElementCopyAttributeValue(windowRef, CFSTR("AXFocusedUIElement"), (CFTypeRef *)&elementRef);

    CFRelease(windowRef);

    if (!elementRef)
        return nil;

    return elementRef;
}


- (NSString *)frontmostTopElementText:(BOOL)selected {
    AXError error = kAXErrorSuccess;
    NSString * value = nil;
    AXUIElementRef elementRef = [self frontmostTopElement:&error];

    if (!elementRef)
        return nil;

    CFTypeRef val = nil;
    error = AXUIElementCopyAttributeValue(elementRef, selected ? CFSTR("AXSelectedText") :CFSTR("AXValue"), (CFTypeRef *)&val);

    CFRelease(elementRef);

    if (val) {
        value = [NSString stringWithString:(NSString *)val];

        CFRelease(val);
    }

    return value;
}


- (void)printAttributesNames:(AXUIElementRef)elementRef {
    NSArray * names = nil;

    AXUIElementCopyAttributeNames(elementRef, (CFArrayRef *)&names);

    NSLog(@"ATTRIBUTES: %@", names);

    CFRelease(names);
}


#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static MKSharedApplication * sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedInstance = [[MKSharedApplication alloc] init];
    });

    return sharedInstance;
}


@end
