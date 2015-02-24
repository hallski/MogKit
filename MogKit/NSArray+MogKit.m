//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "NSArray+MogKit.h"


@implementation NSArray (MogKit)

- (NSArray *)mog_transduce:(MOGTransducer)transducer
{
    return MOGTransduce(self, MOGArrayReducer(), transducer);
}

@end