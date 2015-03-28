//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Block that generates the initial value of a reduction.
 */
typedef id (^MOGReducerInititialBlock) (void);

/**
 * Block that is called by `MOGTransform` after a reduction is done, this to allow step functions or the
 * collection `MOGReducer` to do some final manipulation of the data.
 */
typedef id (^MOGReducerCompleteBlock) (id);

/**
 * A reduce block is passed to `MOGReduce` and is used to collect the accumulated value of the
 * reduction. The block is passed the accumulated value and the next value in order to calculate
 * the next accumulated value.
 *
 * Set stop to YES to terminate the reduction.
 */
typedef id (^MOGReduceBlock) (id acc, id val, BOOL *stop);

/**
* A reducer takes an accumulated value and the next value and combines them into a new accumulated value.
* The return accumulated value is typically passed in as `acc` on successive calls.
*/
@interface MOGReducer : NSObject
@property (nonatomic, copy) MOGReduceBlock reduce;
@property (nonatomic, copy) MOGReducerInititialBlock initial;
@property (nonatomic, copy) MOGReducerCompleteBlock complete;

/**
* Initialize a `MOGReducer` with blocks to create initial value, completion handler and reduce block.
*
* @discussion Use this initializer when writing an output reducer. For implementing transformations use one of the
* stepReducer class methods instead.
*
* @param initBlock a block that creates the initial value for a reduction.
* @param completeBlock block that will be called exactly once after a reduction is complete.
* @param reduceBlock called for each value in the reduction.
*
* @return the reducer
* */
- (instancetype)initWithInitBlock:(MOGReducerInititialBlock)initBlock
                    completeBlock:(MOGReducerCompleteBlock)completeBlock
                      reduceBlock:(MOGReduceBlock)reduceBlock;

/**
 * Class method to create a step reducer (used when implementing transformations).
 *
 * @param reduceBlock called for each value in the reduction.
 *
 * @return a newly created step reducer.
 */
+ (instancetype)stepReducerWithNextReducer:(MOGReducer *)nextReducer reduceBlock:(MOGReduceBlock)reduceBlock;

/**
 * Class method to create a step reducer (used when implementing transformations). Use this when the transformation
 * keeps some state that needs to be flushed after the reduction is done. See the implementation of `MOGPartition` for
 * an example of this.
 *
 * @param completeBlock block that will be called exactly once after a reduction is complete. Note that this block need
 * to chain to nextReducers completeBlock.
 * @param reduceBlock called for each value in the reduction.
 *
 * @return a newly created step reducer.
 */
+ (instancetype)stepReducerWithNextReducer:(MOGReducer *)nextReducer
                               reduceBlock:(MOGReduceBlock)reduceBlock
                             completeBlock:(MOGReducerCompleteBlock)completeBlock;

@end

/**
 * A reducer that accumulates values in an array. If the reducer initial block isn't used to produce the
 * initial value an `NSMutableArray` must be supplied to `MOGReduce` or `MOGTransformWithInitial`.
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
 * A reducer that concatenates string values, with a possible separator. If the reducer initial block isn't used
 * to produce the initial value, a NSMutableString must be supplied to `MOGReduce` or `MOGTransformWithInitial`.
 *
 * @param separator a separator that is inserted between each string
 *
 * @return a reducer collecting values in an array.
 */
MOGReducer *MOGStringConcatReducer(NSString *separator);

/**
 * Applies the `reduceBlock` to each element of `source` and returns the final accumulated
 * value returned by `reduceBlock`.
 *
 * @param source any class conforming to the `NSFastEnumeration` protocol.
 * @param reduceBlock the reduce block to collect some accumulated value.
 * @param initial the initial value passed in as accumulator to the reduce block.
 *
 * @return returns the final return value of `reduceBlock`.
 */
id MOGReduce(id<NSFastEnumeration> source, MOGReduceBlock reduceBlock, id initial);