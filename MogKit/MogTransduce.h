//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MogReduce.h"


typedef MOGReducer (^MOGTransducer) (MOGReducer);

typedef id (^MOGMapFunc) (id);
typedef id (^MOGIndexedMapFunc) (int, id);
typedef BOOL (^MOGPredicate) (id);

MOGTransducer MOGIdentity(void);

MOGTransducer MOGMap(MOGMapFunc mapFunc);
MOGTransducer MOGFilter(MOGPredicate predicate);
MOGTransducer MOGRemove(MOGPredicate predicate); // Reversed MOGFilter
MOGTransducer MOGTake(int n);
MOGTransducer MOGTakeWhile(MOGPredicate predicate);
MOGTransducer MOGTakeNth(int n);
MOGTransducer MOGDrop(int n);
MOGTransducer MOGDropWhile(MOGPredicate predicate);
MOGTransducer MOGReplace(NSDictionary *replacements);
MOGTransducer MOGKeep(MOGMapFunc func);
MOGTransducer MOGKeepIndexed(MOGIndexedMapFunc indexMapFunc);
MOGTransducer MOGUnique(void);
MOGTransducer MOGWindowed(int length);

MOGTransducer MOGCompose(MOGTransducer, MOGTransducer);
MOGTransducer MOGComposeArray(NSArray *transducers);

id MOGTransduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial, MOGTransducer transducer);
