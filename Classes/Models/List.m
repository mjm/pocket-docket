//
//  List.m
//  PocketDocket
//
//  Created by Matt Moriarity on 8/4/10.
//  Copyright 2010 Moriaritronics. All rights reserved.
//

#import "List.h"


@implementation List

- (NSString *)description
{
	return [NSString stringWithFormat:@"<List:%@ title=%@, position=%@, userId=%@>", self.listId, self.title, self.position, self.userId];
}

@end
