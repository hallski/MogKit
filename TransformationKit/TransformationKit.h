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

TKTransducer mapping(TKMapFunc);
TKTransducer filtering(TKPredicate);

id reduce(NSEnumerator *source, id initial, TKReducer reducer);
id transduce(NSEnumerator *source, id initial, TKTransducer transducer, TKReducer reducer);
