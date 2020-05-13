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
    NSButton *const button = [[[NSButton alloc] initWithFrame:rect] autorelease];

    button.title = title;
    button.target = target;
    button.action = action;
    button.buttonType = NSButtonTypeMomentaryLight;
    button.bezelStyle = NSBezelStyleRounded;

    return button;
}


+ (NSTextView *)textViewWithFrame:(NSRect)frame {
    NSTextView *const textView = [[[NSTextView alloc] initWithFrame:frame] autorelease];

    NSMutableParagraphStyle *const style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    style.paragraphSpacing = 4.0f;

    textView.defaultParagraphStyle = style;
    textView.editable = NO;
    textView.backgroundColor = NSColor.clearColor;
    textView.alignment = NSTextAlignmentCenter;
    textView.font = FONT_REGULAR(13.0f);

    return textView;
}


+ (NSTextView *)textViewWithText:(NSString *)text frame:(NSRect)frame {
    NSTextView *const textView = [[[NSTextView alloc] initWithFrame:frame] autorelease];

    textView.editable = NO;
    textView.backgroundColor = NSColor.clearColor;
    textView.font = FONT_REGULAR(13.0f);
    textView.string = text;
    textView.richText = YES;
    textView.alignment = NSTextAlignmentCenter;

    return textView;
}


@end
