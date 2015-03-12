//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MogKit/MogTransformation.h>


@interface NSArray (MogKit)

/**
 * Apply a transformation to the array.
 *
 * This applies the transformation through `MOGTransform` with a NSMutableArray to accumulate the values and finally
 * makes a immutable copy which is passed back.
 *
 * @param transformation the transformation to apply.
 *
 * @return a newly created array contained the transformed values.
 *
 * @see `MOGTransform`
 */
- (NSArray *)mog_transform:(MOGTransformation)transformation;

/**
 * Applies `transformation` to `enumeration` and collects the reduction as an array.
 *
 * @param enumeration the source used for the transformation.
 * @param transformation the transformation to apply to the source.
 *
 * @return a newly created array containing the result of the transformation.
 */
+ (NSArray *)mog_transformedArrayFromEnumeration:(id<NSFastEnumeration>)enumeration transformation:(MOGTransformation)transformation;

@end