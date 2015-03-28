//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "NSObject+MogKit.h"


@implementation NSObject (MogKit)

- (id)mog_transform:(MOGTransformation)transformation reducer:(MOGReducer *)reducer
{
    MOGReducer *xformReducer = transformation(reducer);
    BOOL stop = NO;
    return xformReducer.complete(xformReducer.reduce(xformReducer.initial(), self, &stop));
}

@end