//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <MogKit/MogKit.h>
#import "NSArray+MogKit.h"


@implementation NSArray (MogKit)

- (NSArray *)mog_transform:(MOGTransformation)transformation
{
    return [MOGTransform(self, MOGArrayReducer(), [NSMutableArray new], transformation) copy];
}

+ (NSArray *)mog_transformedArrayFromEnumeration:(id<NSFastEnumeration>)enumeration
                                  transformation:(MOGTransformation)transformation
{
    return [MOGTransform(enumeration, MOGArrayReducer(), [NSMutableArray new], transformation) copy];
}

@end