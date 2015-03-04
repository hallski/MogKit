//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//


#import "MogTransformation.h"

MOGTransformation MOGIdentity(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            return reducer.reduce(acc, val);
        }];
    };
}

MOGTransformation MOGMap(id (^mapFunc)(id))
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            return reducer.reduce(acc, mapFunc(val));
        }];
    };
}

MOGTransformation MOGFilter(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            return predicate(val) ? reducer.reduce(acc, val) : acc;
        }];
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

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            if (taken++ < n) {
                id newAcc = reducer.reduce(acc, val);
                return taken == n ? MOGEnsureReduced(newAcc) : newAcc;
            } else {
                return MOGEnsureReduced(acc);
            }
        }];
    };
}

MOGTransformation MOGTakeWhile(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL keepTaking = YES;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            if (keepTaking) {
                keepTaking = predicate(val);
            }

            return keepTaking ? reducer.reduce(acc, val) : MOGEnsureReduced(acc);
        }];
    };
}

MOGTransformation MOGTakeNth(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger i = 0;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            return (i++ % n == 0) ? reducer.reduce(acc, val) : acc;
        }];
    };
}

MOGTransformation MOGDrop(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger dropped = 0;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            if (dropped < n) {
                dropped++;
                return acc;
            }

            return reducer.reduce(acc, val);
        }];
    };
}

MOGTransformation MOGDropWhile(MOGPredicate predicate) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL keepDropping = YES;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            if (keepDropping) {
                keepDropping = predicate(val);
            }
            return keepDropping ? acc : reducer.reduce(acc, val);
        }];
    };
}

MOGTransformation MOGReplace(NSDictionary *replacements) {
    return MOGReplaceWithDefault(replacements, nil);
}

MOGTransformation MOGReplaceWithDefault(NSDictionary *replacements, id defaultValue)
{
    return MOGMap(^id(id val) {
        id replacement = replacements[val] ?: defaultValue;
        return replacement ?: val;
    });
}

MOGTransformation MOGKeep(MOGMapBlock mapBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            id outValue = mapBlock(val);
            return outValue != nil ? reducer.reduce(acc, outValue) : acc;
        }];
    };
}

MOGTransformation MOGKeepIndexed(MOGIndexedMapBlock indexedMapBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger index = 0;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            id outValue = indexedMapBlock(index++, val);
            return outValue != nil ? reducer.reduce(acc, outValue) : acc;
        }];
    };
}

MOGTransformation MOGUnique(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        NSMutableSet *seenValues = [NSMutableSet new];

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            if ([seenValues containsObject:val]) {
                return acc;
            }

            [seenValues addObject:val];
            return reducer.reduce(acc, val);
        }];
    };
}

MOGTransformation MOGDedupe(void)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id previous = nil;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val) {
            if ([val isEqual:previous]) {
                return acc;
            } else {
                previous = val;
                return reducer.reduce(acc, val);
            }
        }];
    };
}

MOGTransformation MOGConcat(void)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
            if (![val conformsToProtocol:@protocol(NSFastEnumeration)]) {
                // Leave untouched if it's not a fast enumeration
                return reducer.reduce(acc, val);
            }

            MOGReduceBlock keepReduced = ^id(id a, id v) {
                a = reducer.reduce(a, v);
                return MOGIsReduced(a) ? MOGReduced(a) : a;
            };

            return MOGReduce(val, keepReduced, acc);
        }];
    };
}

MOGTransformation MOGMapCat(MOGMapBlock mapBlock)
{
    return MOGCompose(MOGMap(mapBlock), MOGConcat());
}

MOGTransformation MOGPartitionBy(MOGMapBlock partitioningBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id lastPartitionKey = nil;
        __block NSMutableArray *currentPartition = [NSMutableArray new];

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val) {
            id partitionKey = partitioningBlock(val);
            lastPartitionKey = lastPartitionKey ?: partitionKey;

            if ([partitionKey isEqual:lastPartitionKey]) {
                [currentPartition addObject:val];
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                currentPartition = nil;

                id newAcc = reducer.reduce(acc, finishedPartition);
                if (!MOGIsReduced(newAcc)) {
                    currentPartition = [NSMutableArray new];
                    [currentPartition addObject:val];
                    lastPartitionKey = partitionKey;
                }
                return newAcc;
            }
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = MOGUnreduced(reducer.reduce(result, [currentPartition copy]));
                currentPartition = nil;
            }
            return reducer.complete(result);
        }];
    };
}

MOGTransformation MOGPartition(NSUInteger size)
{
    NSCParameterAssert(size > 0);

    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSMutableArray *currentPartition;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val) {
            if (!currentPartition) {
                currentPartition = [NSMutableArray new];
            }
            [currentPartition addObject:val];

            if (currentPartition.count < size) {
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                currentPartition = nil;
                id ret = reducer.reduce(acc, finishedPartition);
                return ret;
            }
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = reducer.reduce(result, [currentPartition copy]);
            }

            return reducer.complete(MOGUnreduced(result));
        }];
    };
}

MOGTransformation MOGWindow(NSUInteger length)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL firstValue = YES;
        NSMutableArray *windowedValues = [NSMutableArray arrayWithCapacity:length];

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val) {
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
        }];
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

id MOGTransform(id<NSFastEnumeration> source, MOGReducer *reducer, MOGTransformation transformation)
{
    return MOGTransformWithInitial(source, reducer, nil, transformation);
}

id MOGTransformWithInitial(id<NSFastEnumeration> source, MOGReducer *reducer, id initial, MOGTransformation transformation)
{
    MOGReducer *tr = transformation(reducer);
    initial = initial ?: tr.initial();
    return tr.complete(MOGReduce(source, tr.reduce, initial));
}
