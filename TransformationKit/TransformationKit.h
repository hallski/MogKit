//
//  TransformationKit.h
//  TransformationKit
//
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^TKReducer) (id acc, id val);
typedef TKReducer (^TKTransducer) (TKReducer);

typedef id (^TKMapFunc) (id);
typedef BOOL (^TKPredicate) (id);

TKTransducer TKMapping(TKMapFunc);
TKTransducer TKFiltering(TKPredicate);
TKTransducer TKIdentityTransducer();

TKTransducer TKComposeTransducers(TKTransducer, TKTransducer);
TKTransducer TKComposeTransducersArray(NSArray *transducers);

id TKReduce(TKReducer reducer, id initial, NSEnumerator *source);
id TKTransduce(TKTransducer transducer, TKReducer reducer, id initial, NSEnumerator *source);

@protocol TKTransformable
- (instancetype)tk_map:(TKMapFunc)mapFunc;
- (instancetype)tk_filter:(TKPredicate)predicate;
- (instancetype)tk_concat;
@end

