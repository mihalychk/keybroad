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



typedef NS_ENUM(NSUInteger, MKSettingsInterfaceType) {
    MKSettingsInterfaceTypeUnknown = 0,
    MKSettingsInterfaceTypeLight,
    MKSettingsInterfaceTypeDark,
};



@interface MKSettings : NSObject

@property (nonatomic, assign) BOOL startup;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL useCaps;
@property (nonatomic, assign) BOOL wasInit;
@property (nonatomic, assign) NSString * layoutForCapsOn;
@property (nonatomic, assign) NSString * layoutForCapsOff;

+ (instancetype)sharedSettings;
- (void)systemVersionMajor:(NSUInteger *)major minor:(NSUInteger *)minor bugFix:(NSUInteger *)bugFix;
- (MKSettingsInterfaceType)currentInterfaceType;

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
