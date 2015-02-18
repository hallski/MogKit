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
TKTransducer TKFlattening(void);

id TKReduce(NSEnumerator *source, id initial, TKReducer reducer);
id TKTransduce(NSEnumerator *source, id initial, TKTransducer transducer, TKReducer reducer);

@protocol TKTransformable
- (instancetype)tk_map:(TKMapFunc)mapFunc;
- (instancetype)tk_filter:(TKPredicate)predicate;
- (instancetype)tk_concat;
@end

