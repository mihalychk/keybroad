//
//  MKCommon.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 05.11.13.
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




#ifndef Keybroad_MKCommon_h
#define Keybroad_MKCommon_h




#define MACRO_VALUE_TO_STRING_(m)      #m
#define MACRO_VALUE_TO_STRING(m)       MACRO_VALUE_TO_STRING_(m)




#define FONT(_fontSize_, _weight_)     ([NSFont respondsToSelector:@selector(systemFontOfSize:weight:)] ? [NSFont systemFontOfSize:_fontSize_ weight:NSFontWeight ## _weight_] : [NSFont fontWithName:@"HelveticaNeue-"MACRO_VALUE_TO_STRING(_weight_)@"" size:_fontSize_])
#define FONT_ITALIC(_fontSize_)        ([NSFont italicSystemFontOfSize:_fontSize_])
#define FONT_ULTRA_LIGHT(_fontSize_)   FONT(_fontSize_, UltraLight)
#define FONT_THIN(_fontSize_)          FONT(_fontSize_, Thin)
#define FONT_LIGHT(_fontSize_)         FONT(_fontSize_, Light)
#define FONT_REGULAR(_fontSize_)       ([NSFont systemFontOfSize:_fontSize_])
#define FONT_MEDIUM(_fontSize_)        FONT(_fontSize_, Medium)
#define FONT_BOLD(_fontSize_)          ([NSFont boldSystemFontOfSize:_fontSize_])




#define RGBA(rVal, gVal, bVal, aVal)   ([NSColor colorWithCalibratedRed:(CGFloat)(rVal) green:(CGFloat)(gVal) blue:(CGFloat)(bVal) alpha:(CGFloat)(aVal)])
#define RGB(rVal, gVal, bVal)          RGBA(rVal, gVal, bVal, 1.0f)
#define RGBC(rVal, gVal, bVal)         (RGB(rVal, gVal, bVal).CGColor)
#define RGB_HEX(_hex_rgb_)             ([NSColor colorWithCalibratedRed:((CGFloat)(((_hex_rgb_) & 0xFF0000) >> 16))/255.0f green:((CGFloat)(((_hex_rgb_) & 0xFF00) >> 8))/255.0f blue:((CGFloat)((_hex_rgb_) & 0xFF))/255.0f alpha:1.0f])




#define FORMAT(...)                    ([NSString stringWithFormat:__VA_ARGS__])
#define URL(_string_)                  ([NSURL URLWithString:_string_])
#define URL_FORMAT(...)                URL(FORMAT(__VA_ARGS__))
#define CSTRING(_value_)               ((NSString *)CFSTR(_value_))




#define BUNDLE_OBJ(_key_)              ([NSBundle.mainBundle objectForInfoDictionaryKey:_key_])




#define IS_VALID(_obj_, _class_)       (_obj_ != nil && [_obj_ isKindOfClass:_class_.class])
#define IS_ARRAY(_obj_)                IS_VALID(_obj_, NSArray)
#define IS_ARRAY_1(_obj_)              (IS_ARRAY(_obj_) && ((NSArray *)_obj_).count > 0)
#define IS_COLOR(_obj_)                IS_VALID(_obj_, NSColor)
#define IS_DATA(_obj_)                 IS_VALID(_obj_, NSData)
#define IS_DATA_1(_obj_)               (IS_DATA(_obj_) && ((NSData *)_obj_).length > 0)
#define IS_DATE(_obj_)                 IS_VALID(_obj_, NSDate)
#define IS_DICT(_obj_)                 IS_VALID(_obj_, NSDictionary)
#define IS_DICT_1(_obj_)               (IS_DICT(_obj_) && ((NSDictionary *)_obj_).count > 0)
#define IS_IMAGE(_obj_)                IS_VALID(_obj_, NSImage)
#define IS_INT_1(_obj_)                (IS_NUMBER(_obj_) && ((NSNumber *)_obj_).integerValue > 0)
#define IS_MARRAY(_obj_)               IS_VALID(vobj, NSMutableArray)
#define IS_MARRAY_1(_obj_)             (IS_MARRAY(_obj_) && ((NSMutableArray *)_obj_).count > 0)
#define IS_MDICT(_obj_)                IS_VALID(_obj_, NSMutableDictionary)
#define IS_MDICT_1(_obj_)              (IS_MDICT(_obj_) && ((NSMutableDictionary *)_obj_).count > 0)
#define IS_NULL(_obj_)                 IS_VALID(_obj_, NSNull)
#define IS_NUMBER(_obj_)               IS_VALID(_obj_, NSNumber)
#define IS_PARSABLE_NUMBER(_obj_)      (IS_NUMBER(_obj_) || IS_STRING(_obj_))
#define IS_SET(_obj_)                  IS_VALID(_obj_, NSSet)
#define IS_SET_1(_obj_)                (IS_SET(_obj_) && ((NSSet *)_obj_).count > 0)
#define IS_STRING(_obj_)               IS_VALID(_obj_, NSString)
#define IS_STRING_1(_obj_)             (IS_STRING(_obj_) && ((NSString *)_obj_).length > 0)
#define IS_UINT_1(_obj_)               (IS_NUMBER(_obj_) && ((NSNumber *)_obj_).unsignedIntegerValue > 0)
#define IS_URL(_obj_)                  IS_VALID(_obj_, NSURL)
#define IS_URL_1(_obj_)                (IS_URL(_obj_) && ((NSURL *)_obj_).absoluteString.length > 0)




#define SBOOL(_value_)                 ((_value_) ? @"YES" : @"NO")
#define SINT(_value_)                  FORMAT(@"%ld", (long)(_value_))
#define SUINT(_value_)                 FORMAT(@"%lu", (unsigned long)(_value_))
#define SFLOAT(_value_, _digitsCount_) FORMAT(@"%."MACRO_VALUE_TO_STRING(_digitsCount_)@"f", (_value_))




#define ASYNCH_MAINTHREAD(_block_)                      dispatch_async(dispatch_get_main_queue(), _block_)
#define ASYNCH_MAINTHREAD_AFTER(_seconds_, _block_)     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_seconds_) * NSEC_PER_SEC)), dispatch_get_main_queue(), _block_);
#define ASYNCH_BACKGROUND(_block_)                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), _block_)




#define MK_WINDOW_X(_window_, _width_)                     (ceil(NSWidth(_window_.screen.frame) / 2.0f) - ceil((_width_) / 2.0f))
#define MK_WINDOW_Y(_window_, _height_)                    (ceil(NSHeight(_window_.screen.frame) / 2.0f) - ceil(((_height_) + 22.0f) / 2.0f))
#define MK_WINDOW_SET_CENTER(_window_, _width_, _height_)  [_window_ setFrame:NSMakeRect(MK_WINDOW_X(_window_, (_width_)), MK_WINDOW_Y(_window_, (_height_)), (_width_), (_height_) + 22.0f) display:YES]



#define WEAKIFY(_obj_) __weak typeof(_obj_) const _obj_ ## Weakified = _obj_



#endif
