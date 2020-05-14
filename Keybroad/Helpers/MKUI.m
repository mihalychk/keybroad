//
//  MKUI.m
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



#import "MKCommon.h"
#import "MKUI.h"



@implementation MKUI


+ (NSButton *)buttonWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action andRect:(NSRect)rect {
    __autoreleasing NSButton *const button = [[NSButton alloc] initWithFrame:rect];

    button.title = title;
    button.target = target;
    button.action = action;
    button.buttonType = NSButtonTypeMomentaryLight;
    button.bezelStyle = NSBezelStyleRounded;

    return button;
}


+ (NSButton *)checkboxWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action {
    __autoreleasing NSButton *const checkbox = [[NSButton alloc] init];

    checkbox.buttonType = NSSwitchButton;
    checkbox.font = FONT_REGULAR(13.0f);
    checkbox.title = title;
    checkbox.target = target;
    checkbox.action = action;

    return checkbox;
}


+ (NSTextView *)textViewWithFrame:(NSRect)frame {
    __autoreleasing NSTextView *const textView = [[NSTextView alloc] initWithFrame:frame];

    NSMutableParagraphStyle *const style = [[NSMutableParagraphStyle alloc] init];
    style.paragraphSpacing = 4.0f;

    textView.defaultParagraphStyle = style;
    textView.editable = NO;
    textView.backgroundColor = NSColor.clearColor;
    textView.alignment = NSTextAlignmentCenter;
    textView.font = FONT_REGULAR(13.0f);

    return textView;
}


+ (NSTextView *)textViewWithText:(NSString *)text frame:(NSRect)frame {
    __autoreleasing NSTextView *const textView = [[NSTextView alloc] initWithFrame:frame];

    textView.editable = NO;
    textView.backgroundColor = NSColor.clearColor;
    textView.font = FONT_REGULAR(13.0f);
    textView.string = text;
    textView.richText = YES;
    textView.alignment = NSTextAlignmentCenter;

    return textView;
}


+ (MKUIInterfaceType)currentInterfaceType {
    NSString *const value = [NSUserDefaults.standardUserDefaults stringForKey:@"AppleInterfaceStyle"];

    if (!IS_STRING_1(value)) {
        return MKUIInterfaceTypeLight;
    }

    if ([value.lowercaseString isEqualToString:@"dark"]) {
        return MKUIInterfaceTypeDark;
    }

    return MKUIInterfaceTypeUnknown;
}


@end
