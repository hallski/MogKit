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


MOGReducer MOGArrayReducer(void)
{
    return ^NSMutableArray *(NSMutableArray *acc, id val) {
        [acc addObject:val];
        return acc;
    };
}


MOGReducer MOGLastValueReducer(void)
{
    return ^id(id _, id val) {
        return val;
    };
}

MOGReducer MOGStringConcatReducer(NSString *separator)
{
    return ^NSMutableString *(NSMutableString *acc, NSString *val) {
        if (!separator || [acc isEqualToString:@""]) {
            [acc appendString:val];
        } else {
            [acc appendFormat:@"%@%@", separator, val];
        }
        return acc;
    };
}

id MOGReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial)
{
    id acc = initial;

    for (id val in source) {
        acc = reducer(acc, val);
        if (MOGIsReduced(acc)) {
            acc = MOGReducedGetValue(acc);
            break;
        }
    }

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

id MOGEnsureReduced(id val)
{
    return MOGIsReduced(val) ? val : MOGReduced(val);
}

id MOGUnreduced(id val)
{
    return MOGIsReduced(val) ? MOGReducedGetValue(val) : val;
}
