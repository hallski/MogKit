//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransformationKit.h"


TKReducer arrayAppendReducer(void);

@interface NSArray (TransformationKit)

- (NSArray *)tk_map:(TKMapFunc)mapFunc;
- (NSArray *)tk_filter:(TKPredicate)predicate;

@end