//
//  MKKeyStore.m
//  Keybroad
//
//  Created by Mikhail Kalinin on 03.02.13.
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




#import "MKKeyStore.h"




@interface MKKeyStore ()

@property (nonatomic, retain) NSMutableArray * store;

@end




@implementation MKKeyStore


#pragma mark - init & dealloc

- (instancetype)init {
    if ((self = [super init]))
        self.store = NSMutableArray.array;

    return self;
}


- (void)dealloc {
    self.store = nil;

    [super dealloc];
}


#pragma mark - Public Methods

- (NSString *)description {
    return self.store.description;
}


- (void)addSymbol:(NSString *)symbol {
    if (!symbol)
        return;

    if (self.store.count >= 50)        // These symbols are for extra needs
        [self.store removeLastObject];

    [self.store insertObject:symbol atIndex:0];
}


- (void)backspace {
    if (self.store.count >= 1)
        [self.store removeObjectAtIndex:0];
}


- (NSString *)symbolAtIndex:(NSUInteger)index {
    if (index >= self.store.count)
        return nil;

    return self.store[index];
}


- (NSString *)symbols:(NSUInteger)count {
    NSEnumerator * enumerator = self.store.reverseObjectEnumerator;
    NSMutableString * result = NSMutableString.string;
    NSString * letter = nil;

    while ((letter = enumerator.nextObject))
        [result appendString:letter];

    NSInteger index = result.length - count;
    index = index > 0 ? index : 0;

    return [result substringFromIndex:index];
}


- (void)invalidate {
    [self.store removeAllObjects];
}


- (NSUInteger)count {
    return self.store.count;
}


#pragma mark - Singleton

+ (instancetype)keyStore {
    static MKKeyStore * keyStore = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        keyStore = [[MKKeyStore alloc] init];
    });

    return keyStore;
}


@end
