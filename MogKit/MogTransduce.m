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

MOGTransducer MOGIdentityTransducer(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return reducer.reduce(acc, val);
        });
    };
}

MOGTransducer MOGMapTransducer(id (^mapFunc)(id))
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return reducer.reduce(acc, mapFunc(val));
        });
    };
}

MOGTransducer MOGFilterTransducer(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return predicate(val) ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransducer MOGRemoveTransducer(MOGPredicate predicate) {
    return MOGFilterTransducer(^BOOL(id val) {
        return !predicate(val);
    });
}

MOGTransducer MOGTakeTransducer(NSUInteger n)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger taken = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return taken++ < n ? reducer.reduce(acc, val) : MOGEnsureReduced(acc);
        });
    };
}

MOGTransducer MOGTakeWhileTransducer(MOGPredicate predicate)
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

MOGTransducer MOGTakeNthTransducer(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger i = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return (i++ % n == 0) ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransducer MOGDropTransducer(NSUInteger n) {
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

MOGTransducer MOGDropWhileTransducer(MOGPredicate predicate) {
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

MOGTransducer MOGReplaceTransducer(NSDictionary *replacements) {
    return MOGReplaceWithDefaultTransducer(replacements, nil);
}

MOGTransducer MOGReplaceWithDefaultTransducer(NSDictionary *replacements, id defaultValue)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            id replacement = replacements[val] ?: defaultValue;
            replacement = replacement ?: val;
            return reducer.reduce(acc, replacement);
        });
    };
}

MOGTransducer MOGKeepTransducer(MOGMapBlock mapBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return mapBlock(val) != nil ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransducer MOGKeepIndexedTransducer(MOGIndexedMapBlock func) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger index = 0;

        return SimpleStepReducer(reducer, ^(id acc, id val) {
            return func(index++, val) != nil ? reducer.reduce(acc, val) : acc;
        });
    };
}

MOGTransducer MOGUniqueTransducer(void) {
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

MOGTransducer MOGDedupeTransducer(void)
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


MOGTransducer MOGCatTransducer(void)
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

MOGTransducer MOGMapCatTransducer(MOGMapBlock mapBlock)
{
    return MOGCompose(MOGMapTransducer(mapBlock), MOGCatTransducer());
}


MOGTransducer MOGPartitionByTransducer(MOGMapBlock partitioningBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id lastPartitionKey = nil;
        __block NSMutableArray *currentPartition = nil;

        return [[MOGReducer alloc] initWithInitBlock:^id {
            return reducer.initial();
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = reducer.reduce(result, [currentPartition copy]);
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
                currentPartition = [NSMutableArray arrayWithObject:val];
                lastPartitionKey = partitionKey;

                return reducer.reduce(acc, finishedPartition);
            }
        }];
    };
}

MOGTransducer MOGPartitionTransducer(NSUInteger size)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSMutableArray *currentPartition = [NSMutableArray new];

        return [[MOGReducer alloc] initWithInitBlock:^id {
            return reducer.initial();
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = reducer.reduce(result, [currentPartition copy]);
                return reducer.complete(result);
            } else {
                return result;
            }
        } reduceBlock:^id(id acc, id val) {
            [currentPartition addObject:val];

            if (currentPartition.count < size) {
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                currentPartition = [NSMutableArray new];
                return reducer.reduce(acc, finishedPartition);
            }
        }];
    };
}

MOGTransducer MOGWindowTransducer(NSUInteger length)
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
MOGTransducer MOGCompose(MOGTransducer f, MOGTransducer g)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return f(g(reducer));
    };
}

MOGTransducer MOGComposeArray(NSArray *transducers)
{
    return MOGReduce(transducers, ^id(id f, id g) { return MOGCompose(f, g); }, MOGIdentityTransducer());
}

id MOGTransduce(id<NSFastEnumeration> source, MOGReducer *reducer, MOGTransducer transducer)
{
    return MOGTransduceWithInitial(source, reducer, reducer.initial(), transducer);
}

id MOGTransduceWithInitial(id<NSFastEnumeration> source, MOGReducer *reducer, id initial, MOGTransducer transducer)
{
    MOGReducer *tr = transducer(reducer);
    return tr.complete(MOGReduce(source, tr.reduce, initial));
}
