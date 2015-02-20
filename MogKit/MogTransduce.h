//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MogReduce.h"


/**
 * A transducer takes a `MOGReducer` and returns a new `MOGReducer` with some transformation applied.
 */
typedef MOGReducer (^MOGTransducer) (MOGReducer);

/**
 * A `MOGMapFunc` is a function you typically send to `MOGMap` which is a transformation of a single value
 * into a new value.
 */
typedef id (^MOGMapFunc) (id val);

/**
 * `MOGIndexedMapFunc` is the same as `MOGMapFunc`, only it also includes the index of the value in sequence
 * that is being processed.
 */
typedef id (^MOGIndexedMapFunc) (int index, id val);

/**
 * `MOGPredicate` is a function that by examining the value returns YES or NO. It's typically used in `MOGFilter` or
 * `MOGKeep`.
 */
typedef BOOL (^MOGPredicate) (id val);

/**
 * Returns a transducer that doesn't transform the values.
 * This is useful as an input if you are reducing over a list of transducers.
 *
 * @return the identity transducer.
 */
MOGTransducer MOGIdentity(void);

/**
 * Creates a transducer that applies the `mapFunc` to transform each value passed through the transformation.
 *
 * @param mapFunc the transformation function.
 *
 * @return a transducer that applies the map transformation.
 */
MOGTransducer MOGMap(MOGMapFunc mapFunc);

/**
 * Creates a transducer that filters all values based on the `predicate` function. Values where `predicate` returns
 * NO are dropped.
 *
 * @param predicate the predicate function. Return YES to let the values through, NO to drop the value.
 *
 * @return a transducer that filters values keeps values where the predicate returns YES.
 */
MOGTransducer MOGFilter(MOGPredicate predicate);

/**
 * Creates a transducer that removes all values where the `predicate` function returns YES.
 * This is the reverse of `MOGFilter`.
 *
 * @param predicate the predicate function. Return YES to drop the values, NO to let them through.
 *
 * @return a transducer that remove values where predicate returns YES.
 */
MOGTransducer MOGRemove(MOGPredicate predicate);

/**
 * Creates a transducer that let `n` values through and then drops all remaining values passed through it.
 *
 * @param n the number of values to pass through.
 *
 * @return a transducer that takes `n` values and then drops all remaining values.
 *
 * @see `MOGDrop`
 */
MOGTransducer MOGTake(int n);

/**
 * Creates a transducer that pass values through while the `predicate` function returns YES. After the predicate
 * returns NO, all successive values are dropped.
 *
 * @param predicate the predicate function, return YES to let values through, NO to drop all remaining values.
 *
 * @return a transducer that takes values until `predicate` returns NO and drops all remaining values.
 */
MOGTransducer MOGTakeWhile(MOGPredicate predicate);

/**
 * Creates a transducer that pass through every nth value and drops the other.
 *
 * @param n determines which values to pass through.
 *
 * @return a transducer that returns every n values.
 */
MOGTransducer MOGTakeNth(int n);

/**
 * Creates a transducer that drops the first `n` values and pass through all successive values.
 *
 * @param n number of values to drop.
 *
 * @return a transducer that drops the n first values.
 *
 * @see `MOGTake`
 */
MOGTransducer MOGDrop(int n);

/**
 * Creates a transducer that drops all values while the `predicate` function returns YES.
 * After that all values are passed through
 *
 * @param predicate the predicate function deciding whether to keep dropping values.
 *
 * @return a transducer that drops all values until the predicate function returns YES.
 *
 * @see MOGTakeWhile
 */
MOGTransducer MOGDropWhile(MOGPredicate predicate);

/**
 * Creates a transducer that replaces values if they are found in the `replacements` dictionary. For each value it will
 * try to locate it as a key in the `replacements` dictionary, if found the corresponding value will be used instead,
 * otherwise the original value will be passed on unfiltered.
 *
 * @param replacements a dictionary container values and replacements.
 *
 * @return a transducer that replaces all values found in `replacements`.
 *
 * @warning Keep in mind that if the replacements dictionary can't replace all values it should return the same type
 *          as the values passed in.
 */
MOGTransducer MOGReplace(NSDictionary *replacements);

/**
 * Creates a transducer that keep values where `func` returns a non-nil value and drops all where nil is returned.
 *
 * @warning Keep in mind that the original value is passed on, not the value returned by `func`.
 *
 * @param func a function that determines if the transducer should pass on a value or not. non-nil to pass on,
 *        nil to drop it.
 *
 * @return a transducer that drops all values where `func` returns nil.
 *
 * @see `MOGFilter`, `MOGRemove` and `MOGKeepIndexed`.
 */
MOGTransducer MOGKeep(MOGMapFunc func);

/**
 * Creates a transducer a transducer that keeps values where `func` returns a non-nil value. This is similar to
 * `MOGKeep` with the difference that the index of the value is passed to `func` as well.
 *
 * @param func a function that determines if the transducer should pass on a value or not. non-nil to pass on,
 *        nil to drop it.
 *
 * @return a transducer that drops all values where `func` returns nil.
 *
 * @see `MOGFilter`, `MOGRemove` and `MOGKeep`.
 */
MOGTransducer MOGKeepIndexed(MOGIndexedMapFunc func);

/**
 * Creates a transducer that drops all consecutive duplicates. Whether it's a duplicate is determined by `isEqual:`
 *
 * @return a transducer that drops all consecutive duplicates.
 */
MOGTransducer MOGUnique(void);


/**
 * Creates a transducer that creates a window of size `length` by examining the values passed through.
 * The window will always contain the last `length` values passed through. Until `length` values have passed through
 * the window will contain the first value in all slots. Each value passed through is replaced by an array with the
 * current window content.
 *
 * @param length the length of the window.
 *
 * @return a transducer that replaces each value with an array containing the current window content.
 */
MOGTransducer MOGWindowed(int length);

/**
 * Creates the composite transducer by applying `g` to `f`.
 *
 * @param f the first transducer
 * @param g the second transducer
 *
 * @return a composite transducer of applied `g` to `f`.
 */
MOGTransducer MOGCompose(MOGTransducer f, MOGTransducer g);

/**
 * Creates a transducer which is the composition of `transducers`.
 *
 * @param transducers an `NSArray` of `MOGTransducer`s.
 *
 * @return a composite transducer of all transducers in `transducers`.
 */
MOGTransducer MOGComposeArray(NSArray *transducers);

/**
 * Applied the transformation to `source`. This is the step when input, transformation and output are combined
 * to transform the source values into output values based on the `reducer` and the `initial` value.
 *
 * @param source any class conforming to the `NSFastEnumeration` protocol.
 * @param reducer the reducer function to collect the transformed values into the result of this function.
 * @param initial the initial value to pass as the accumulator to `reducer`.
 * @param transducer the transformation to apply.
 *
 * @return the final value collected by `reducer.
 */
id MOGTransduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial, MOGTransducer transducer);
