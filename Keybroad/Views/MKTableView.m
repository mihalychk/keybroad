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

@property (nonatomic, retain) NSScrollView * scrollView;
@property (nonatomic, retain) NSTableView * tableView;

@end




@implementation MKTableView


#pragma mark - Helpers

- (NSTableColumn *)columnWithTypeImage:(BOOL)type identifier:(NSString *)identifier andWidth:(CGFloat)width {
	NSTableColumn * column = [[[NSTableColumn alloc] initWithIdentifier:identifier] autorelease];
	column.width = width;
	column.editable = NO;
	
	if (type)
		column.dataCell = [[[NSCell alloc] initImageCell:nil] autorelease];

    else
		column.dataCell = [[[NSCell alloc] initTextCell:@""] autorelease];
	
	return column;
}


#pragma mark - init & dealloc

- (instancetype)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.wantsLayer = YES;
		self.layer.masksToBounds = YES;
		self.layer.borderColor = RGBC(0.84f, 0.84f, 0.84f);
		self.layer.borderWidth = 1.0f;

		self.scrollView = [[[NSScrollView alloc] initWithFrame:NSZeroRect] autorelease];

		[self addSubview:self.scrollView];

		self.tableView = [[[NSTableView alloc] initWithFrame:NSZeroRect] autorelease];
		NSTableColumn * imageColumn = [self columnWithTypeImage:YES identifier:@"image" andWidth:32.0f];
		NSTableColumn * titleColumn = [self columnWithTypeImage:NO identifier:@"title" andWidth:157.0f];

		[self.tableView addTableColumn:imageColumn];
		[self.tableView addTableColumn:titleColumn];
		
		self.tableView.dataSource = self;
		self.tableView.delegate = self;
		self.tableView.backgroundColor = NSColor.whiteColor;
		self.tableView.rowHeight = 16.0f;
		self.tableView.intercellSpacing = NSMakeSize(0.0f, 10.0f);
		self.tableView.focusRingType = NSFocusRingTypeNone;
		self.tableView.headerView = nil;
		self.tableView.allowsEmptySelection = NO;
		self.tableView.allowsMultipleSelection = NO;

		self.scrollView.documentView = self.tableView;
	}

	return self;
}


- (void)dealloc {
	self.delegate = nil;
    self.layouts = nil;
    self.scrollView = nil;
    self.tableView = nil;

	[super dealloc];
}


#pragma mark - NSView Stuff

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	[super resizeSubviewsWithOldSize:oldBoundsSize];

	NSSize size = self.frame.size;
	self.scrollView.frame = NSMakeRect(1.0f, 1.0f, size.width - 2.0f, size.height - 2.0f);
}


#pragma mark - Public Methods

- (void)selectNextIndex {
	if (self.layouts.count == 1)
		return;

	NSInteger index = 0;
	
	if (self.tableView.selectedRow < (self.layouts.count - 1))
		index = self.tableView.selectedRow + 1;

	self.selectedIndex = index;
}


#pragma mark - Getters & Setters

- (void)setLayouts:(NSArray *)value {
	[value retain];
	[_layouts release];
	
	_layouts = value;
	
	[self.tableView reloadData];
}


- (void)setSelectedIndex:(NSInteger)index {
	if (index < 0 || index > (self.layouts.count - 1))
		return;
	
	[self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
}


- (NSInteger)selectedIndex {
	return self.tableView.selectedRow;
}


- (void)setEnabled:(BOOL)value {
	[(NSControl *)self.tableView setEnabled:value];
}


- (BOOL)enabled {
	return [(NSControl *)self.tableView isEnabled];
}


#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return self.layouts.count;
}


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSCell * columnCell = (NSCell *)cell;
	NSDictionary * item = self.layouts[row];
	
	if (columnCell.type == NSTextCellType)
		columnCell.title = item[@"title"];

    else
		columnCell.image = item[@"image"];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return nil;
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	if (notification.object == self.tableView)
		if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndex:)])
			[self.delegate tableView:self didSelectRowAtIndex:self.selectedIndex];
}


@end
