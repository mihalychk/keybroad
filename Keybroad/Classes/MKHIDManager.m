//
//  MKHIDManager.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 13.09.13.
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




#import "MKHIDManager.h"
#import "MKCommon.h"




@interface MKHIDManager() {
    IOHIDManagerRef hidManager;
}

@end




@implementation MKHIDManager


#pragma mark - init & dealloc

- (instancetype)init {
	if ((self = [super init])) {
		hidManager = MKHIDManager.hidManager;
        
        IOHIDManagerRegisterInputValueCallback(hidManager, myHIDKeyboardCallback, self);
		IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
		IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
	}

	return self;
}


- (void)dealloc {
	self.delegate = nil;

    if (hidManager) {
        IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
        IOHIDManagerUnscheduleFromRunLoop(hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        CFRelease(hidManager);
    }

	[super dealloc];
}


#pragma mark - Static Methods

+ (IOHIDManagerRef)hidManager {
	IOHIDManagerRef HIDManagerRef = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);

    NSDictionary * keyboard = [self matchingDeviceDictionaryWithPage:kHIDPage_GenericDesktop andUsage:kHIDUsage_GD_Keyboard];
    NSDictionary * leds = [self matchingDeviceDictionaryWithPage:kHIDPage_LEDs andUsage:kHIDUsage_Undefined];
    NSArray * matches = [NSArray arrayWithObjects:keyboard, leds, nil];
	
	IOHIDManagerSetDeviceMatchingMultiple(HIDManagerRef, (CFArrayRef)matches);
	
	return HIDManagerRef;
}


+ (NSDictionary *)matchingDeviceDictionaryWithPage:(UInt32)page andUsage:(UInt32)usage {
    NSMutableDictionary * result = NSMutableDictionary.dictionary;

    if (page != kHIDPage_Undefined)
        result[CSTRING(kIOHIDDeviceUsagePageKey)] = @(page);

    if (usage != kHIDUsage_Undefined)
        result[CSTRING(kIOHIDDeviceUsageKey)] = @(usage);
    
    return [NSDictionary dictionaryWithDictionary:result]; // autoreleased
}


+ (NSDictionary *)matchingElementDictionaryWithPage:(UInt32)page andUsage:(UInt32)usage {
    NSMutableDictionary * result = NSMutableDictionary.dictionary;
    
    if (page != kHIDPage_Undefined)
        result[(NSString *)CFSTR(kIOHIDElementUsagePageKey)] = @(page);
    
    if (usage != kHIDUsage_Undefined)
        result[(NSString *)CFSTR(kIOHIDElementUsageKey)] = @(usage);
    
    return [NSDictionary dictionaryWithDictionary:result]; // autoreleased
}


#pragma mark - MKHIDManagerDelegate

- (void)onCapsLock {
	if ([self.delegate respondsToSelector:@selector(hidManagerDidPressCapsLock:)])
		[self.delegate hidManagerDidPressCapsLock:self];
}

 
- (void)setCapsState:(BOOL)newState {
    CFSetRef deviceCFSetRef = IOHIDManagerCopyDevices(hidManager);
    CFIndex deviceCount = CFSetGetCount(deviceCFSetRef);
    IOHIDDeviceRef * deviceRefs = malloc(sizeof(IOHIDDeviceRef) * deviceCount);
    
    CFSetGetValues(deviceCFSetRef, (const void **)deviceRefs);
    CFRelease(deviceCFSetRef);
    
    NSDictionary * matches = [MKHIDManager matchingElementDictionaryWithPage:kHIDPage_LEDs andUsage:kHIDUsage_LED_CapsLock];
    
    for (NSUInteger deviceIndex = 0; deviceIndex < deviceCount; deviceIndex++) {
        if (!IOHIDDeviceConformsTo(deviceRefs[deviceIndex], kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard))
            continue;
        
        NSArray * elements = (NSArray *)IOHIDDeviceCopyMatchingElements(deviceRefs[deviceIndex], (CFDictionaryRef)matches, kIOHIDOptionsTypeNone);
        
        for (NSUInteger index = 0; index < elements.count; index++) {
            IOHIDElementRef elementRef = (IOHIDElementRef)elements[index];
            uint32_t usagePage = IOHIDElementGetUsagePage(elementRef);
            uint32_t usage = IOHIDElementGetUsage(elementRef);
            
            if (usagePage != kHIDPage_LEDs || usage != kHIDUsage_LED_CapsLock)
                continue;

            IOHIDValueRef valueRef = IOHIDValueCreateWithIntegerValue(kCFAllocatorDefault, elementRef, 0, newState ? 1 : 0);
            
            if (valueRef) {
                IOHIDDeviceSetValue(deviceRefs[deviceIndex], elementRef, valueRef);
                CFRelease(valueRef);
            }
        }
        
        [elements release];
    }
    
    free(deviceRefs);
}


#pragma mark - HID Callbacks

void myHIDKeyboardCallback(void * context, IOReturn result, void * sender, IOHIDValueRef value) {
	IOHIDElementRef elem = IOHIDValueGetElement(value);

    if (IOHIDElementGetUsagePage(elem) != kHIDPage_KeyboardOrKeypad)
		return;

	uint32_t scancode = IOHIDElementGetUsage(elem);

	if (scancode != kHIDUsage_KeyboardCapsLock)
		return;

	long pressed = IOHIDValueGetIntegerValue(value); // 1 - pressed, 0 - released

	if (pressed == 0)
		dispatch_async(dispatch_get_main_queue(), ^{
			[(MKHIDManager *)context onCapsLock];
		});
}


@end
