//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransformationKit.h"


TKReducer arrayAppendReducer(void);
TKReducer arrayAppendArrayReducer(void);

@interface NSArray (TransformationKit) <TKTransformable>
@end