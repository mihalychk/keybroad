//
//  MKSystemSettingsWindow.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 24.04.13.
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



NS_ASSUME_NONNULL_BEGIN



typedef void (^MKSystemSettingsCallback)(BOOL onSettings);



@interface MKSystemSettingsWindow : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNewStyle:(BOOL)newStyle andCallback:(nullable MKSystemSettingsCallback)callback NS_DESIGNATED_INITIALIZER;

@end



NS_ASSUME_NONNULL_END
