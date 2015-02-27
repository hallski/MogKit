//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <MogKit/MogKit.h>
#import "MogTransduce.h"

MOGReducer *SimpleStepReducer(MOGReducer *nextReducer, MOGReduceBlock stepBlock) {
    return [[MOGReducer alloc] initWithInitBlock:^{ return nextReducer.initial(); }
                                   completeBlock:^(id result) { return nextReducer.complete(result); }
                                     reduceBlock:stepBlock];
}

MOGTransformation MOGIdentity(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return reducer.reduce(acc, val);
        });
    };
}

MOGTransformation MOGMap(id (^mapFunc)(id))
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return reducer.reduce(acc, mapFunc(val));
        });
    };
}

MOGTransformation MOGFilter(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return predicate(val) ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransformation MOGRemove(MOGPredicate predicate) {
    return MOGFilter(^BOOL(id val) {
        return !predicate(val);
    });
}

MOGTransformation MOGTake(NSUInteger n)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger taken = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return taken++ < n ? reducer.reduce(acc, val) : MOGEnsureReduced(acc);
        });
    };
}

MOGTransformation MOGTakeWhile(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL keepTaking = YES;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            if (keepTaking) {
                keepTaking = predicate(val);
            }

            return keepTaking ? reducer.reduce(acc, val) : MOGEnsureReduced(acc);
        });
    };
}

MOGTransformation MOGTakeNth(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger i = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return (i++ % n == 0) ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransformation MOGDrop(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger dropped = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            if (dropped < n) {
                dropped++;
                return acc;
            }

            return reducer.reduce(acc, val);
        });
    };
}

MOGTransformation MOGDropWhile(MOGPredicate predicate) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL keepDropping = YES;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            if (keepDropping) {
                keepDropping = predicate(val);
            }
            return keepDropping ? acc : reducer.reduce(acc, val);
        });
    };
}

MOGTransformation MOGReplace(NSDictionary *replacements) {
    return MOGReplaceWithDefault(replacements, nil);
}

MOGTransformation MOGReplaceWithDefault(NSDictionary *replacements, id defaultValue)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            id replacement = replacements[val] ?: defaultValue;
            replacement = replacement ?: val;
            return reducer.reduce(acc, replacement);
        });
    };
}

MOGTransformation MOGKeep(MOGMapBlock mapBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return mapBlock(val) != nil ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransformation MOGKeepIndexed(MOGIndexedMapBlock func) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger index = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return func(index++, val) != nil ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransformation MOGUnique(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        NSMutableSet *seenValues = [NSMutableSet new];

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            if ([seenValues containsObject:val]) {
                return acc;
            }

            [seenValues addObject:val];
            return reducer.reduce(acc, val);
        });
    };
}

MOGTransformation MOGDedupe(void)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id previous = nil;

        return SimpleStepReducer(reducer, ^id(id acc, id val) {
            if ([val isEqual:previous]) {
                return acc;
            } else {
                previous = val;
                return reducer.reduce(acc, val);
            }
        });
    };
}


MOGTransformation MOGCat(void)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            if (![val conformsToProtocol:@protocol(NSFastEnumeration)]) {
                // Leave untouched if it's not a fast enumeration
                return reducer.reduce(acc, val);
            }

            MOGReduceBlock keepReduced = ^id(id a, id v) {
                a = reducer.reduce(a, v);
                return MOGIsReduced(a) ? MOGReduced(a) : a;
            };

            return MOGReduce(val, keepReduced, acc);
        });
    };
}

MOGTransformation MOGMapCat(MOGMapBlock mapBlock)
{
    return MOGCompose(MOGMap(mapBlock), MOGCat());
}


MOGTransformation MOGPartitionBy(MOGMapBlock partitioningBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id lastPartitionKey = nil;
        __block NSMutableArray *currentPartition = nil;

        return [[MOGReducer alloc] initWithInitBlock:^id {
            return reducer.initial();
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = MOGUnreduced(reducer.reduce(result, [currentPartition copy]));
                return reducer.complete(result);
            } else {
                return result;
            }
        } reduceBlock:^id(id acc, id val) {
            id partitionKey = partitioningBlock(val);
            if (lastPartitionKey == nil) {
                lastPartitionKey = partitionKey;
                currentPartition = [NSMutableArray new];
            }
            if ([partitionKey isEqual:lastPartitionKey]) {
                [currentPartition addObject:val];
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                id ret = reducer.reduce(acc, finishedPartition);
                if (!MOGIsReduced(ret)) {
                    currentPartition = [NSMutableArray arrayWithObject:val];
                    lastPartitionKey = partitionKey;
                }
                return ret;
            }
        }];
    };
}

MOGTransformation MOGPartition(NSUInteger size)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSMutableArray *currentPartition = [NSMutableArray new];
        __block BOOL reduced = NO;

        return [[MOGReducer alloc] initWithInitBlock:^id {
            return reducer.initial();
        } completeBlock:^id(id result) {
            if (!reduced && currentPartition.count > 0) {
                result = reducer.reduce(result, [currentPartition copy]);
            }

            return reducer.complete(MOGUnreduced(result));
        } reduceBlock:^id(id acc, id val) {
            [currentPartition addObject:val];

            if (currentPartition.count < size) {
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                currentPartition = [NSMutableArray new];
                id ret = reducer.reduce(acc, finishedPartition);
                reduced = MOGIsReduced(ret);
                return ret;
            }
        }];
    };
}

MOGTransformation MOGWindow(NSUInteger length)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL firstValue = YES;
        NSMutableArray *windowedValues = [NSMutableArray arrayWithCapacity:length];

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            if (firstValue) {
                for (NSUInteger i = 0; i < length; ++i) {
                    [windowedValues addObject:val];
                }
                firstValue = NO;
            } else {
                [windowedValues removeObjectAtIndex:0];
                [windowedValues addObject:val];
            }

            return reducer.reduce(acc, [windowedValues copy]);
        });
    };
}

#pragma mark - Transducer Composition
MOGTransformation MOGCompose(MOGTransformation f, MOGTransformation g)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return f(g(reducer));
    };
}

MOGTransformation MOGComposeArray(NSArray *transducers)
{
    return MOGReduce(transducers, ^id(id f, id g) { return MOGCompose(f, g); }, MOGIdentity());
}

id MOGTransduce(id<NSFastEnumeration> source, MOGReducer *reducer, MOGTransformation transducer)
{
    return MOGTransduceWithInitial(source, reducer, reducer.initial(), transducer);
}

id MOGTransduceWithInitial(id<NSFastEnumeration> source, MOGReducer *reducer, id initial, MOGTransformation transducer)
{
    MOGReducer *tr = transducer(reducer);
    return tr.complete(MOGReduce(source, tr.reduce, initial));
}
