//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * A reducer is passed to `MOGReduce` and is used to collect the accumulated value of the
 * reduction. The block is passed the accumulated value and the next value in order to calculate
 * the next accumulated value.
 */
typedef id (^MOGReducer) (id acc, id val);

/**
 * A reducer that accumulates values in a mutable array. The user needs to make sure a `NSMutableArray` is passed in
 * as initial value to `MOGReduce` or `MOGTransform`.
 *
 * @return a reducer collecting values in a mutable array.
 */
MOGReducer MOGArrayReducer(void);

/**
 * A reducer that ignores the accumulated value and simply always returns the last value it received. This is useful
 * when only the final value of a computation is used.
 */
MOGReducer MOGLastValueReducer(void);

/**
 * A reducer that concatenates string values, with a possible separator. The user needs to make sure a
 * `NSMutableString` is passed in as initial value to `MOGReduce` or `MOGTransform`.
 *
 * @param separator a separator that is inserted between each string
 *
 * @return a reducer collecting values in an array.
 */
MOGReducer MOGStringConcatReducer(NSString *separator);

/**
 * Applies the `reducer` to each element of `source` and returns the final accumulated
 * value returned by `reducer`.
 *
 * @param source any class conforming to the `NSFastEnumeration` protocol.
 * @param reducer the reducer block to collect some accumulated value.
 * @param initial the initial value passed in as accumulator to the reducer.
 *
 * @return returns the final return value of `reducer`.
 */
id MOGReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial);

/**
 * Wraps `value` to signal that a reduction is done. `MOGReduce` will look at the value returned
 * after each iteration to decide on whether the process has completed. If so, it will unwrap the
 * value with `MOGReducedGetValue` and return it.
 *
 * @param the value to wrap
 *
 * @return a reduced value to indicate that the reduction is done.
 */
id MOGReduced(id value);

/**
 * Checks whether `value` is a value wrapped to indicate that the reduction is done. This is used
 * by `MOGReduce` to decide on whether it should continue with the reduction.
 *
 * @param the value to check
 *
 * @return YES if `value` is a reduced value.
 */
BOOL MOGIsReduced(id value);

/**
 * Unwraps the value from the reduced wrapped and returns it.
 *
 * @param the reduced value
 *
 * @return the unwrapped original value.
 */
id MOGReducedGetValue(id reducedValue);

/**
 * Ensures that a value is wrapped as a reduced value. If `val` is already reduced, it's
 * returned, otherwise it's wrapped as reduced.
 *
 * @param val the value
 *
 * @return a reduced value
 */
id MOGEnsureReduced(id val);

/**
 * If `val` is reduced, it's unwrapped, otherwise it's returned.
 *
 * @param val the possibly reduced value.
 *
 * @return a possibly unwrapped value.
 */
id MOGUnreduced(id val);