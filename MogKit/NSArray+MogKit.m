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
    return MOGTransform(self, MOGArrayReducer(), transformation);
}

+ (NSArray *)mog_transformedArrayFromEnumeration:(id<NSFastEnumeration>)enumeration
                                  transformation:(MOGTransformation)transformation
{
    return MOGTransform(enumeration, MOGArrayReducer(), transformation);
}

- (NSArray *)mog_map:(MOGMapFunc)mapBlock
{
    return [self mog_transform:MOGMap(mapBlock)];
}

- (NSArray *)mog_filter:(MOGPredicate)predicate
{
    return [self mog_transform:MOGFilter(predicate)];
}

@end