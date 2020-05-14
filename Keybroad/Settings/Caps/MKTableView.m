//
//  MKTableView.m
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



#import "MKTableView.h"
#import "MKCommon.h"



@interface MKTableView () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, nullable, weak) NSScrollView *scrollView;
@property (nonatomic, nullable, weak) NSTableView *tableView;

@end



@implementation MKTableView


#pragma mark - Helpers

+ (NSTableColumn *)columnWithTypeImage:(BOOL)type identifier:(NSString *)identifier andWidth:(CGFloat)width {
    __autoreleasing NSTableColumn *const column = [[NSTableColumn alloc] initWithIdentifier:identifier];
    column.width = width;
    column.editable = NO;

    if (type) {
        column.dataCell = [[NSCell alloc] initImageCell:nil];
    }
    else {
        column.dataCell = [[NSCell alloc] initTextCell:@""];
    }

    return column;
}


#pragma mark - init & dealloc

- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0f;

        NSScrollView *const scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];

        [self addSubview:scrollView];

        self.scrollView = scrollView;

        NSTableView *const tableView = [[NSTableView alloc] initWithFrame:NSZeroRect];

        NSTableColumn *const imageColumn = [self.class columnWithTypeImage:YES identifier:@"image" andWidth:32.0f];
        NSTableColumn *const titleColumn = [self.class columnWithTypeImage:NO identifier:@"title" andWidth:157.0f];

        [tableView addTableColumn:imageColumn];
        [tableView addTableColumn:titleColumn];

        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 16.0f;
        tableView.intercellSpacing = NSMakeSize(0.0f, 10.0f);
        tableView.focusRingType = NSFocusRingTypeNone;
        tableView.headerView = nil;
        tableView.allowsEmptySelection = NO;
        tableView.allowsMultipleSelection = NO;

        self.scrollView.documentView = tableView;
        self.tableView = tableView;
    }

    return self;
}


#pragma mark - NSView Stuff

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
    [super resizeSubviewsWithOldSize:oldBoundsSize];

    NSSize size = self.frame.size;
    self.scrollView.frame = NSMakeRect(1.0f, 1.0f, size.width - 2.0f, size.height - 2.0f);
}


#pragma mark - Public Methods

- (void)selectNextIndex {
    if (self.layouts.count == 1) {
        return;
    }

    NSInteger index = 0;

    if (self.tableView.selectedRow < (self.layouts.count - 1)) {
        index = self.tableView.selectedRow + 1;
    }

    self.selectedIndex = index;
}


#pragma mark - Getters & Setters

- (void)setLayouts:(nullable NSArray *)value {
    _layouts = value;

    [self.tableView reloadData];
}


- (void)setSelectedIndex:(NSInteger)index {
    if (index < 0 || index > (self.layouts.count - 1)) {
        return;
    }

    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
}


- (NSInteger)selectedIndex {
    return self.tableView.selectedRow;
}


- (void)setEnabled:(BOOL)value {
    [(NSControl *)self.tableView setEnabled:value];
}


- (BOOL)enabled {
    return ((NSControl *)self.tableView).isEnabled;
}


#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.layouts.count;
}


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSCell *const columnCell = (NSCell *)cell;
    NSDictionary *const item = self.layouts[row];

    if (columnCell.type == NSTextCellType) {
        columnCell.title = item[@"title"];
    }
    else {
        columnCell.image = item[@"image"];
    }
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.tableView) {
        [self.delegate tableView:self didSelectRowAtIndex:self.selectedIndex];
    }
}


@end
