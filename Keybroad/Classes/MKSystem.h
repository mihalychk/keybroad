//
//  MKSystem.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 14.05.20.
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



#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN



@interface MKSystem : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (BOOL)isApplicationStartingUp;
+ (void)enableApplicationStartUp:(BOOL)enabled;
+ (void)disableCapsLockStandardBehavior:(BOOL)disable;
+ (void)osVersionMajor:(NSUInteger *)major minor:(NSUInteger *)minor bugFix:(NSUInteger *)bugFix;

@end



NS_ASSUME_NONNULL_END
