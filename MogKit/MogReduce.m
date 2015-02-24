//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MogReduce.h"

MOGReducer *MOGArrayReducer(void)
{
    return [[MOGReducer alloc] initWithInitBlock:^id {
        return [NSMutableArray new];
    } completeBlock:^id(NSMutableArray *result) {
        return [result copy];
    } reduceBlock:^id(NSMutableArray *acc, id val) {
        [acc addObject:val];
        return acc;
    }];
}


MOGReducer *MOGLastValueReducer(void)
{
    return [[MOGReducer alloc] initWithInitBlock:^id {
        return nil;
    } completeBlock:^id(id o) {
        return o;
    } reduceBlock:^id(id acc, id val) {
        return val;
    }];
}

id MOGReduce(id<NSFastEnumeration> source, MOGReducer *reducer, id initial)
{
    id acc = initial ?: reducer.initial();

    for (id val in source) {
        acc = reducer.reduce(acc, val);
    }

    reducer.complete(acc);

    return acc;
}


@implementation MOGReducer

- (instancetype)initWithInitBlock:(id(^)(void))initBlock
                    completeBlock:(id(^)(id))completeBlock
                      reduceBlock:(MOGReducerReduceBlock)reduceBlock
{
    if (self = [super init]) {
        self.initial = initBlock;
        self.complete = completeBlock;
        self.reduce = reduceBlock;
    }

    return self;
}

@end