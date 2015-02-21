//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MogKit/MogTransduce.h>


@interface NSArray (MogKit)

/**
 * Apply a transducer to the array.
 *
 * This applies the transducer through `MOGTransduce` with a NSMutableArray to accumulate the values and finally
 * makes a immutable copy which is passed back.
 *
 * @param transducer the transducer to apply.
 *
 * @return a newly created array containined the transduced values.
 *
 * @see `MOGTransduce`
 */
- (NSArray *)mog_transduce:(MOGTransducer)transducer;

@end