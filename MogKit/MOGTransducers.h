//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MogTypes.h"

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

