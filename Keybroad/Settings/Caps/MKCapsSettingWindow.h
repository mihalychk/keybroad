//
//  MKCapsSettingWindow.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 03.11.13.
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
#import "MKTableView.h"



NS_ASSUME_NONNULL_BEGIN



@protocol MKCapsSettingWindowDelegate;
typedef void (^MKCapsSettingCallback)(void);



@interface MKCapsSettingWindow : NSObject

@property (nonatomic, nullable, assign) id<MKCapsSettingWindowDelegate> delegate;
@property (nonatomic, nullable, retain) NSArray *layouts;
@property (nonatomic, assign) BOOL useCaps;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCallback:(nullable MKCapsSettingCallback)callback NS_DESIGNATED_INITIALIZER;

- (void)setCapsOnLayout:(nullable NSString *)layoutName;
- (void)setCapsOffLayout:(nullable NSString *)layoutName;

@end



@protocol MKCapsSettingWindowDelegate <NSObject>

@optional

- (void)settingWindow:(MKCapsSettingWindow *)window didSwitchUseState:(BOOL)state;
- (void)settingWindow:(MKCapsSettingWindow *)window didSelectIndex:(NSInteger)index forCapsState:(BOOL)state;

@end



NS_ASSUME_NONNULL_END
