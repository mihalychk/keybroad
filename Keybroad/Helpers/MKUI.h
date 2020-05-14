//
//  MKUI.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 13.05.20.
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



#import <Cocoa/Cocoa.h>



NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(NSUInteger, MKUIInterfaceType) {
    MKUIInterfaceTypeUnknown = 0,
    MKUIInterfaceTypeLight,
    MKUIInterfaceTypeDark,
};



@interface MKUI : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (NSButton *)buttonWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action andRect:(NSRect)rect;
+ (NSButton *)checkboxWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (NSTextView *)textViewWithFrame:(NSRect)frame;
+ (NSTextView *)textViewWithText:(NSString *)text frame:(NSRect)frame;
+ (MKUIInterfaceType)currentInterfaceType;

@end



NS_ASSUME_NONNULL_END
