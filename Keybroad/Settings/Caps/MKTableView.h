//
//  MKTableView.h
//  Keybroad
//
//  Created by Mikhail Kalinin on 07.11.13.
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



#import <Cocoa/Cocoa.h>



NS_ASSUME_NONNULL_BEGIN



@protocol MKTableViewDelegate;



@interface MKTableView : NSView

@property (nonatomic, nullable, weak) id<MKTableViewDelegate> delegate;
@property (nonatomic, nullable, strong) NSArray *layouts;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL enabled;

- (void)selectNextIndex;

@end



@protocol MKTableViewDelegate <NSObject>

- (void)tableView:(MKTableView *)tableView didSelectRowAtIndex:(NSInteger)index;

@end



NS_ASSUME_NONNULL_END
