//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MogReduce.h"

@interface MOGReducedWrapper : NSObject
@property (nonatomic, strong) id value;
- (instancetype)initWithValue:(id)value;
@end


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
        if (MOGIsReduced(acc)) {
            acc = MOGReducedGetValue(acc);
            break;
        }
    }

    reducer.complete(acc);

    return acc;
}

@implementation MOGReducedWrapper
- (instancetype)initWithValue:(id)value
{
    if (self = [super init]) {
        self.value = value;
    }
    return self;
}

@end


id MOGReduced(id value)
{
    return [[MOGReducedWrapper alloc] initWithValue:value];
}

BOOL MOGIsReduced(id value)
{
    return [value isKindOfClass:[MOGReducedWrapper class]];
}

id MOGReducedGetValue(id reducedValue)
{
    return ((MOGReducedWrapper *)reducedValue).value;
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