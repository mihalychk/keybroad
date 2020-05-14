//
//  MKStatusItemView.h
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




#import <Cocoa/Cocoa.h>



NS_ASSUME_NONNULL_BEGIN



@protocol MKStatusItemViewDelegate;



@interface MKStatusItemView : NSControl

@property (nonatomic, nullable, weak) id<MKStatusItemViewDelegate> delegate;
@property (nonatomic, nullable, strong) NSImage *image;
@property (nonatomic, nullable, strong) NSImage *alternateImage;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(NSRect)frameRect NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)initWithStatusBarItem:(NSStatusItem *)statusItem NS_DESIGNATED_INITIALIZER;

- (void)popUpMenu:(NSMenu *)menu;

@end



@protocol MKStatusItemViewDelegate <NSObject>

- (void)statusItemViewDidClick:(MKStatusItemView *)itemView;
- (void)statusItemViewDidRightClick:(MKStatusItemView *)itemView;

@optional

- (void)statusItemViewDidAltClick:(MKStatusItemView *)itemView;
- (void)statusItemViewDidRightAltClick:(MKStatusItemView *)itemView;

@end



NS_ASSUME_NONNULL_END
