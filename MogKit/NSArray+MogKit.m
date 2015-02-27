//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <MogKit/MogKit.h>
#import "NSArray+MogKit.h"


@implementation NSArray (MogKit)

- (NSArray *)mog_transduce:(MOGTransformation)transducer
{
    return MOGTransform(self, MOGArrayReducer(), transducer);
}

+ (NSArray *)mog_transducedArrayFromEnumeration:(id<NSFastEnumeration>)enumeration transducer:(MOGTransformation)transducer
{
    return MOGTransform(enumeration, MOGArrayReducer(), transducer);
}

@end