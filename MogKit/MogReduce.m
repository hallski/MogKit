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
    } reduceBlock:^id(NSMutableArray *acc, id val, BOOL *stop) {
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
    } reduceBlock:^id(id acc, id val, BOOL *stop) {
        return val;
    }];
}

MOGReducer *MOGStringConcatReducer(NSString *separator)
{
    return [[MOGReducer alloc] initWithInitBlock:^id {
        return [NSMutableString new];
    } completeBlock:^id(NSMutableString *result) {
        return [result copy];
    } reduceBlock:^id(NSMutableString *acc, NSString *val, BOOL *stop) {
        if (!separator || [acc isEqualToString:@""]) {
            [acc appendString:val];
        } else {
            [acc appendFormat:@"%@%@", separator, val];
        }
        return acc;
    }];
}

id MOGReduce(id<NSFastEnumeration> source, MOGReduceBlock reduceBlock, id initial)
{
    id acc = initial;

    for (id val in source) {
        BOOL stop = NO;
        acc = reduceBlock(acc, val, &stop);
        if (stop) {
            break;
        }
    }

    return acc;
}

@implementation MOGReducer

- (instancetype)initWithInitBlock:(id(^)(void))initBlock
                    completeBlock:(id(^)(id))completeBlock
                      reduceBlock:(MOGReduceBlock)reduceBlock
{
    if (self = [super init]) {
        self.initial = initBlock;
        self.complete = completeBlock;
        self.reduce = reduceBlock;
    }

    return self;
}

+ (instancetype)stepReducerWithNextReducer:(MOGReducer *)nextReducer reduceBlock:(MOGReduceBlock)reduceBlock
{
    return [self stepReducerWithNextReducer:nextReducer
                                reduceBlock:reduceBlock
                              completeBlock:^id(id result) {
                                  return nextReducer.complete(result);
                              }];
}

+ (instancetype)stepReducerWithNextReducer:(MOGReducer *)nextReducer
                               reduceBlock:(MOGReduceBlock)reduceBlock
                             completeBlock:(id(^)(id))completeBlock
{
    return [[self alloc] initWithInitBlock:^id { return nextReducer.initial(); }
                             completeBlock:completeBlock
                               reduceBlock:reduceBlock];
}

@end