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

/**
 * Convenience method for calling `-mog_transform:` with `MOGMap`.
 *
 * @param the mapBlock to pass to `MOGMap`.
 *
 * @return a newly created array with the transformed values.
 */
- (NSArray *)mog_map:(MOGMapFunc)mapBlock;

/**
 * Convenience method for calling `-mog_transform:` with `MOGFilter`.
 *
 * @param predicate the predicate passed to `MOGFilter`.
 *
 * @return a newly created array with the values passing the predicate.
 */
- (NSArray *)mog_filter:(MOGPredicate)predicate;

@end