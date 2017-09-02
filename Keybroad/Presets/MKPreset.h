//
//  MKPreset.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 06.02.13.
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




@interface MKPreset : NSObject

@property (nonatomic, readonly) NSString * title;
@property (nonatomic, readonly) NSString * group;
@property (nonatomic, readonly) NSUInteger order;
@property (nonatomic, readonly) NSArray  * rules;
@property (nonatomic, readonly) NSArray<NSString *> * layouts;
@property (nonatomic, assign)   BOOL       active;
@property (nonatomic, readonly) BOOL       hidden;

- (instancetype)initWithPresetName:(NSString *)name;
- (NSString *)apply:(NSString *)source fromStart:(BOOL)fromStart; // autoreleased
- (BOOL)check:(NSString *)source fromStart:(BOOL)fromStart;
- (void)reload;

@end
