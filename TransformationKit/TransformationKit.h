//
//  TransformationKit.h
//  TransformationKit
//
//  Created by Mikael Hallendal on 18/02/15.
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^TKReducer) (id acc, id val);
typedef TKReducer (^TKTransducer) (TKReducer);

typedef id (^TKMapFunc) (id);
typedef BOOL (^TKPredicate) (id);

TKTransducer mapping(TKMapFunc);
TKTransducer filtering(TKPredicate);

id reduce(NSEnumerator *source, id initial, TKReducer reducer);

TKReducer arrayAppendReducer(void);

@interface NSArray (TransformKit)

- (NSArray *)tk_map:(TKMapFunc)mapFunc;
- (NSArray *)tk_filter:(TKPredicate)predicate;

@end
