//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MogKit/MogTransformation.h>


@interface NSObject (MogKit)

/**
 * Applies `transformation` to the object and collects the result in `reducer`.
 *
 * @param transformation the transformation to apply to the object.
 * @param reducer the reducer to use for collecting the result.
 * @param initial the initial value passed into the transformation as accumulated value.
 *
 * @return the transformed value.
 */
- (id)mog_transform:(MOGTransformation)transformation reducer:(MOGReducer)reducer initial:(id)initial;

@end
