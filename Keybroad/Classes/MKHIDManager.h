//
//  MKHIDManager.h
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



#import <Foundation/Foundation.h>
#ifndef IOHIDManagerRef
#   import <IOKit/hid/IOHIDLib.h>
#endif



@protocol MKHIDManagerDelegate;



@interface MKHIDManager : NSObject

@property (nonatomic, assign) id<MKHIDManagerDelegate> delegate;

+ (IOHIDManagerRef)hidManager;

- (void)setCapsState:(BOOL)value;

@end



@protocol MKHIDManagerDelegate <NSObject>

@optional

- (void)hidManagerDidPressCapsLock:(MKHIDManager *)hidManager;

@end
