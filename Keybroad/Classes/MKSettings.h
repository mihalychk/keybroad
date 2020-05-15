//
//  MKSettings.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 31.03.13.
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



@interface MKSettings : NSObject

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL useCapsToIndicate;
@property (nonatomic, assign) BOOL useCapsToSwitch;
@property (nonatomic, assign) BOOL wasInit;
@property (nonatomic, nullable, copy) NSString *layoutForCapsOn;
@property (nonatomic, nullable, copy) NSString *layoutForCapsOff;

+ (instancetype)sharedSettings;

- (void)addExcludedApp:(NSString *)bundleId;
- (void)removeExcludedApp:(NSString *)bundleId;
- (BOOL)isExcluded:(NSString *)bundleId;

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(nullable id)object forKey:(NSString *)key;
- (void)saveObject:(nullable id)object forKey:(NSString *)key;

- (BOOL)boolForKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)saveBool:(BOOL)value forKey:(NSString *)key;

- (void)saveSettings;

@end



NS_ASSUME_NONNULL_END




#define SETTINGS (MKSettings.sharedSettings)
