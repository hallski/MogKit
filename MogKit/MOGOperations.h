//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MogTypes.h"


id MOGEnumerationReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial);
id MOGEnumerationTransduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial, MOGTransducer transducer);
