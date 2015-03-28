//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//


#import <MogKit/MogKit.h>
#import "MogTransformation.h"

MOGTransformation MOGIdentity(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            return reducer.reduce(acc, val, stop);
        }];
    };
}

MOGTransformation MOGMap(id (^mapFunc)(id))
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            return reducer.reduce(acc, mapFunc(val), stop);
        }];
    };
}

MOGTransformation MOGFilter(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            return predicate(val) ? reducer.reduce(acc, val, stop) : acc;
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

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if (taken++ < n) {
                id newAcc = reducer.reduce(acc, val, stop);
                if (taken == n) {
                    if (stop) {
                        *stop = YES;
                    }
                }
                return newAcc;
            } else {
                return acc;
            }
        }];
    };
}

MOGTransformation MOGTakeWhile(MOGPredicate predicate)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL keepTaking = YES;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if (keepTaking) {
                keepTaking = predicate(val);
            }

            if (keepTaking) {
                return reducer.reduce(acc, val, stop);
            } else {
                if (stop) {
                    *stop = YES;
                }
                return acc;
            }
        }];
    };
}

MOGTransformation MOGTakeNth(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger i = 0;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            return (i++ % n == 0) ? reducer.reduce(acc, val, stop) : acc;
        }];
    };
}

MOGTransformation MOGDrop(NSUInteger n) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block NSUInteger dropped = 0;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if (dropped < n) {
                dropped++;
                return acc;
            }

            return reducer.reduce(acc, val, stop);
        }];
    };
}

MOGTransformation MOGDropWhile(MOGPredicate predicate) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL keepDropping = YES;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if (keepDropping) {
                keepDropping = predicate(val);
            }
            return keepDropping ? acc : reducer.reduce(acc, val, stop);
        }];
    };
}

MOGTransformation MOGDropNil(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val, BOOL *stop) {
            return val != nil ? reducer.reduce(acc, val, stop) : acc;
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

MOGTransformation MOGMapDropNil(MOGMapFunc mapBlock) {
    return MOGCompose(MOGMap(mapBlock), MOGDropNil());
}

MOGTransformation MOGUnique(void) {
    return ^MOGReducer *(MOGReducer *reducer) {
        NSMutableSet *seenValues = [NSMutableSet new];

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if ([seenValues containsObject:val]) {
                return acc;
            }

            [seenValues addObject:val];
            return reducer.reduce(acc, val, stop);
        }];
    };
}

MOGTransformation MOGDedupe(void)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id previous = nil;

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val, BOOL *stop) {
            if ([val isEqual:previous]) {
                return acc;
            } else {
                previous = val;
                return reducer.reduce(acc, val, stop);
            }
        }];
    };
}

MOGTransformation MOGFlatten(void)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if (![val conformsToProtocol:@protocol(NSFastEnumeration)]) {
                // Leave untouched if it's not a fast enumeration
                return reducer.reduce(acc, val, stop);
            }

            for (id v in val) {
                acc = reducer.reduce(acc, v, stop);
                if (stop && *stop) {
                    break;
                }
            }

            return acc;
        }];
    };
}

MOGTransformation MOGFlatMap(MOGMapFunc mapBlock)
{
    return MOGCompose(MOGMap(mapBlock), MOGFlatten());
}

MOGTransformation MOGPartitionBy(MOGMapFunc partitioningBlock) {
    return ^MOGReducer *(MOGReducer *reducer) {
        __block id lastPartitionKey = nil;
        __block NSMutableArray *currentPartition = [NSMutableArray new];

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val, BOOL *stop) {
            id partitionKey = partitioningBlock(val);
            lastPartitionKey = lastPartitionKey ?: partitionKey;

            if ([partitionKey isEqual:lastPartitionKey]) {
                [currentPartition addObject:val];
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                currentPartition = nil;

                id newAcc = reducer.reduce(acc, finishedPartition, stop);
                if (!stop || !*stop) {
                    currentPartition = [NSMutableArray new];
                    [currentPartition addObject:val];
                    lastPartitionKey = partitionKey;
                }
                return newAcc;
            }
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = reducer.reduce(result, [currentPartition copy], NULL);
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

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^id(id acc, id val, BOOL *stop) {
            if (!currentPartition) {
                currentPartition = [NSMutableArray new];
            }
            [currentPartition addObject:val];

            if (currentPartition.count < size) {
                return acc;
            } else {
                NSArray *finishedPartition = [currentPartition copy];
                currentPartition = nil;
                return reducer.reduce(acc, finishedPartition, stop);
            }
        } completeBlock:^id(id result) {
            if (currentPartition.count > 0) {
                result = reducer.reduce(result, [currentPartition copy], NULL);
            }

            return reducer.complete(result);
        }];
    };
}

MOGTransformation MOGWindow(NSUInteger length)
{
    return ^MOGReducer *(MOGReducer *reducer) {
        __block BOOL firstValue = YES;
        NSMutableArray *windowedValues = [NSMutableArray arrayWithCapacity:length];

        return [MOGReducer stepReducerWithNextReducer:reducer reduceBlock:^(id acc, id val, BOOL *stop) {
            if (firstValue) {
                for (NSUInteger i = 0; i < length; ++i) {
                    [windowedValues addObject:val];
                }
                firstValue = NO;
            } else {
                [windowedValues removeObjectAtIndex:0];
                [windowedValues addObject:val];
            }

            return reducer.reduce(acc, [windowedValues copy], stop);
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
    return MOGReduce(transducers, ^id(id f, id g, BOOL *stop) { return MOGCompose(f, g); }, MOGIdentity());
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

MOGMapFunc MOGValueTransformer(MOGTransformation transformation) {
    MOGReducer *reducer = transformation(MOGLastValueReducer());

    return ^id(id val) {
        return reducer.reduce(nil, val, NULL);
    };
}
