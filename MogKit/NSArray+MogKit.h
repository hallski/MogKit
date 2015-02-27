//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MogKit/MogTransformation.h>


@interface NSArray (MogKit)

/**
 * Apply a transducer to the array.
 *
 * This applies the transducer through `MOGTransform` with a NSMutableArray to accumulate the values and finally
 * makes a immutable copy which is passed back.
 *
 * @param transducer the transducer to apply.
 *
 * @return a newly created array containined the transduced values.
 *
 * @see `MOGTransduce`
 */
- (NSArray *)mog_transform:(MOGTransformation)transducer;

/**
 * Applied `transformation` to `enumeration` and collects the reduction as an array.
 *
 * @param enumeration the source used for transducing.
 * @param transformation the transformation to apply to the source.
 *
 * @return a newly created array containing the result of the transformation.
 */
+ (NSArray *)mog_transformedArrayFromEnumeration:(id<NSFastEnumeration>)enumeration transformation:(MOGTransformation)transformation;

@end