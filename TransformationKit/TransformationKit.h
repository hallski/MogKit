//
//  TransformationKit.h
//  TransformationKit
//
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TKEnumerable <NSObject>
- (id)tk_nextValue;
@end

typedef id (^TKReducer) (id acc, id val);
typedef TKReducer (^TKTransducer) (TKReducer);

typedef id (^TKMapFunc) (id);
typedef BOOL (^TKPredicate) (id);

TKTransducer TKMapping(TKMapFunc);
TKTransducer TKFiltering(TKPredicate);
TKTransducer TKIdentityTransducer();
TKTransducer TKTaking(int n);
TKTransducer TKTakeWhile(TKPredicate);

TKTransducer TKComposeTransducers(TKTransducer, TKTransducer);
TKTransducer TKComposeTransducersArray(NSArray *transducers);

id TKReduce(TKReducer reducer, id initial, id<TKEnumerable> source);
id TKTransduce(TKTransducer transducer, TKReducer reducer, id initial, id<TKEnumerable> source);


@interface NSEnumerator (TKTransformable) <TKEnumerable>

- (id)tk_reduce:(TKReducer)reducer initial:(id)initial;
- (id)tk_transduce:(TKTransducer)transducer reducer:(TKReducer)reducer initial:(id)initial;

@end

@protocol TKTransformable
- (instancetype)tk_map:(TKMapFunc)mapFunc;
- (instancetype)tk_filter:(TKPredicate)predicate;
- (instancetype)tk_concat;
@end

