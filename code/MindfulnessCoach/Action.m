//
//  Action.m
//

#import "Action.h"


@implementation Action

#pragma mark - Attributes

@dynamic accessoryType;
@dynamic completed;
@dynamic details;
@dynamic filename;
@dynamic group;
@dynamic helpFilename;
@dynamic icon;
@dynamic instructions;
@dynamic navigationTitle;
@dynamic rank;
@dynamic section;
@dynamic style;
@dynamic title;
@dynamic type;
@dynamic uid;
@dynamic userInfo;

#pragma mark - Relationships

@dynamic children;
@dynamic parent;

/**
 *  sortedChildren
 */
- (NSArray *)childrenSortedByRank {
  NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
  NSArray *sortedArray = [self.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
  return sortedArray;
}

@end
