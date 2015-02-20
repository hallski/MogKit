//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^MOGReducer) (id acc, id val);
typedef MOGReducer (^MOGTransducer) (MOGReducer);

typedef id (^MOGMapFunc) (id);
typedef id (^MOGIndexedMapFunc) (int, id);
typedef BOOL (^MOGPredicate) (id);

@protocol MOGEnumerable<NSObject>
- (id)mog_nextValue;
@end
