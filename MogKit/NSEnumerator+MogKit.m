//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "NSEnumerator+MogKit.h"

#import "MOGOperations.h"


@implementation NSEnumerator (TKTransformable)

- (id)mog_nextValue
{
    return [self nextObject];
}

@end
