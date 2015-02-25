//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef id (^MOGReducerInititialBlock) (void);
typedef id (^MOGReducerCompleteBlock) (id);
typedef id (^MOGReduceBlock) (id acc, id val);

/**
* A reducer takes an accumulated value and the next value and combines them into a new accumulated value.
* The return accumulated value is typically passed in as `acc` on successive calls.
*/
@interface MOGReducer : NSObject
@property (nonatomic, copy) MOGReduceBlock reduce;
@property (nonatomic, copy) MOGReducerInititialBlock initial;
@property (nonatomic, copy) MOGReducerCompleteBlock complete;

- (instancetype)initWithInitBlock:(id(^)(void))initBlock
                    completeBlock:(id(^)(id))completeBlock
                      reduceBlock:(MOGReduceBlock)reduceBlock;

@end

/**
 * A reducer that accumulates values in an array. If the reducer initial function isn't used to produce the
 * initial value an `NSMutableArray` need to be supplied to `MOGReduce` or `MOGTransduceWithInitial`.
 *
 * When calling complete an immutable copy is returned.
 *
 * @return a reducer collecting values in an array.
 */
MOGReducer *MOGArrayReducer(void);

/**
 * A reducer that ignores the accumulated value and simply always returns the last value it received. This is useful
 * when only the final value of a computation is used.
 */
MOGReducer *MOGLastValueReducer(void);

/**
 * Applies the `reducer` to each element of `source` and returns the final accumulated value returned by `reduce`.
 *
 * @param source any class conforming to the `NSFastEnumeration` protocol.
 * @param reducer the reducer function to collect some accumulated value.
 * @param initial the initial value passed in as accumulator to the reducer.
 *
 * @return returns the final return value of `reducer`.
 */
id MOGReduce(id<NSFastEnumeration> source, MOGReduceBlock reduceBlock, id initial);

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
 * by `MOGReduce` to decide on whether it should continue with the reduction. Any implementor
 * of another transducer based process need to check the return value after each iteration.
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
