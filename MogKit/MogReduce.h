//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
* A reducer takes an accumulated value and the next value and combines them into a new accumalated value.
* The return accumulated value is typically passed in as `acc` on successive calls.
*/
typedef id (^MOGReducer) (id acc, id val);

/**
 * A reducer that accumulates values by creating new `NSArray`s for each value by calling `arrayByAddingObject:`.
 * When calling `MOGReduce` or `MOGTransduce` an empty `NSArray` should be used as initial value.
 *
 * @warning Creating new `NSArray`s for each value isn't particularly effective so when working with longer
 *          streams of values it is better to use `MOGMutableArrayAppendReducer`.
 *
 * @return a reducer collecting values in an `NSArray`.
 *
 * @see `MOGMutableArrayAppendReducer`
 */
MOGReducer MOGArrayAppendReducer(void);

/**
 * A reducer that accumulates values by appending them to a mutable array. This is significantly more effective
 * than using `MOGArrayAppendReducer`. When calling `MOGReduce` or `MOGTransduce` an empty `NSMutableArray` should be
 * used as initial value.
 *
 * @return a reducer collecting values in an `NSMutableArray`.
 *
 * @see `MOGArrayAppendReducer`.
 */
MOGReducer MOGMutableArrayAppendReducer(void);

/**
 * A reducer that ignores the accumulated value and simply always returns the last value it received. This is useful
 * when only the final value of a computation is used.
 */
MOGReducer MOGLastValueReducer(void);

/**
 * Applies the `reducer` to each element of `source` and returns the final accumulated value returned by `reduce`.
 *
 * @param source any class conforming to the `NSFastEnumeration` protocol.
 * @param reducer the reducer function to collect some accumulated value.
 * @param initial the initial value passed in as accumulator to the reducer.
 *
 * @return returns the final return value of `reducer.
 */
id MOGReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial);
