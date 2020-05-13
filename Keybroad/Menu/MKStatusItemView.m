//
//  MKStatusItemView.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 03.02.13.
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



#import "MKStatusItemView.h"



@interface MKStatusItemView ()

@property (nonatomic, assign) BOOL isMenuVisible;
@property (nonatomic, assign) BOOL isMouseDown;
@property (nonatomic, nullable, retain) NSStatusItem *statusItem;

- (void)menuWillOpen:(NSNotification *)notification;
- (void)menuDidClose:(NSNotification *)notification;

@end



@implementation MKStatusItemView


#pragma mark - init & dealloc

- (instancetype)initWithStatusBarItem:(NSStatusItem *)statusItem {
    NSParameterAssert(statusItem);

    if ((self = [super initWithFrame:NSZeroRect])) {
        self.statusItem = statusItem;
    }

    return self;
}


- (void)dealloc {
    self.alternateImage = nil;
    self.delegate = nil;
    self.image = nil;
    self.statusItem = nil;

    [super dealloc];
}


#pragma mark - Getters & Setters

- (void)setImage:(nullable NSImage *)value {
    [value retain];
    [_image release];

    _image = value;

    [self setNeedsDisplay];
}


- (void)setAlternateImage:(nullable NSImage *)value {
    [value retain];
    [_alternateImage release];

    _alternateImage = value;

    [self setNeedsDisplay];
}


#pragma mark - NSView

- (void)drawRect:(NSRect)rect {
    BOOL const highlighted = self.isMouseDown || self.isMenuVisible;

    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:highlighted];

    NSSize const imageSize = self.image.size;
    NSPoint const location = NSMakePoint(ceil((self.bounds.size.width - imageSize.width) / 2), ceil((self.bounds.size.height - imageSize.height) / 2));
    NSRect imageRect = NSMakeRect(location.x, location.y, imageSize.width, imageSize.height);

    imageRect.origin.y++;

    if (highlighted) {
        [self.alternateImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    else {
        [self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}


#pragma mark - NSControl

- (void)mouseDown:(NSEvent *)theEvent {
    self.isMouseDown = YES;

    [self setNeedsDisplay];
}


- (void)mouseUp:(NSEvent *)event {
    if (!self.isMouseDown) {
        return;
    }

    if ((event.modifierFlags & NSAlternateKeyMask) > 0) {
        if ([self.delegate respondsToSelector:@selector(statusItemViewDidAltClick:)]) {
            [self.delegate statusItemViewDidAltClick:self];
        }
    }
    else {
        [self.delegate statusItemViewDidClick:self];
    }

    self.isMouseDown = NO;

    [self setNeedsDisplay];
}


- (void)rightMouseDown:(NSEvent *)theEvent {
    self.isMouseDown = YES;

    [self setNeedsDisplay];
}


- (void)rightMouseUp:(NSEvent *)event {
    if (!self.isMouseDown) {
        return;
    }

    if ((event.modifierFlags & NSAlternateKeyMask) > 0) {
        if ([self.delegate respondsToSelector:@selector(statusItemViewDidRightAltClick:)]) {
            [self.delegate statusItemViewDidRightAltClick:self];
        }
    }
    else {
        [self.delegate statusItemViewDidRightClick:self];
    }

    self.isMouseDown = NO;

    [self setNeedsDisplay];
}


#pragma mark - Menu

- (void)popUpMenu:(NSMenu *)menu {
    NSParameterAssert(menu);

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(menuWillOpen:) name:NSMenuDidBeginTrackingNotification object:menu];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(menuDidClose:) name:NSMenuDidEndTrackingNotification object:menu];

    [self.statusItem popUpStatusItemMenu:menu];
}


#pragma mark - Notifications

- (void)menuWillOpen:(NSNotification *)notification {
    self.isMenuVisible = YES;

    [self setNeedsDisplay];

    [NSNotificationCenter.defaultCenter removeObserver:self name:NSMenuDidBeginTrackingNotification object:notification.object];
}


- (void)menuDidClose:(NSNotification *)notification {
    self.isMenuVisible = NO;

    [self setNeedsDisplay];

    [NSNotificationCenter.defaultCenter removeObserver:self name:NSMenuDidEndTrackingNotification object:notification.object];
}


@end
