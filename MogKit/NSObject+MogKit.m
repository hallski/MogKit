//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "NSObject+MogKit.h"


@implementation NSObject (MogKit)

- (id)mog_transform:(MOGTransformation)transformation reducer:(MOGReducer)reducer initial:(id)initial
{
    MOGReducer xformReducer = transformation(reducer);
    return xformReducer(initial, self);
}

@end