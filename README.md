# MogKit
[![Build Status](https://travis-ci.org/mhallendal/MogKit.svg?branch=master)](https://travis-ci.org/mhallendal/MogKit)

MogKit is a toolkit that makes heavy use of _Transducers_ in order to create composable transformations that are independent from the underlying context they are working on.

Since transducers work by compositing rather then chaining it means that the input values are only iterated over once and not one time per operation.

For an introduction to transducers, see [Clojure - Transducers](http://clojure.org/transducers) and the presentation by Clojure creator [Rich Hickey](https://www.youtube.com/watch?v=6mTbuzafcII).

## Use cases
There are several cases where using MogKit might make sense. Easiest shown with some example.

### Simply transform data
When you simply want to transform some data in for example an array into a new array.

```objective-c
NSArray *array = @[@1, @2, @3];
NSArray *result = [array mog_transduce:MOGMapTransducer(^id(NSNumber *number) {
    return @(number.intValue + 100);
});

// result is now @[@101, @102, @103]
```

### Use to easily implement some transformation functions
Another case is when you have some data structure and want to add a transformation method to it, for example extending `NSArray` and give it a `filter` method, all you need to do is

```objective-c
@implementation NSArray (Filterable)

- (NSArray *)filter:(MOGPredicate)predicate
{
    return [self mog_transduce:MOGFilterTransducer(predicate)];
}

@end
```

### Combine to create new transformations
Say you want to add a `trim:` method to `NSArray` that returns a new array with `trimSize` elements removed from the start and end.
```objective-c
- (NSArray *)trim:(NSUInteger)trimSize 
{
    return [self mog_transduce:MOGCompose(MOGDropTransducer(trimSize), MOGTakeTransducer(self.count - 2 * trimSize))];
}
```

### Non-collection use cases
Using MogKit isn't limited to containers implementing `NSFastEnumeration`. You can easily make use of it to add composable transformation to anything where you want to transform a set of values. Here is an example adding a `-transform:` method to `RACStream` (from [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)) in order to apply the passed in transducer to all values on the stream. This can be used instead of chaining a several of RACStreams built in transformations.

```objective-c
@implementation RACStream (MogKit)

- (instancetype)transform:(MOGTransducer)transducer
{
    Class class = self.class;
    
    // Map all values to a RAC return value.
    MOGTransducer transducerWithMapToRAC = MOGCompose(transducer, MOGMapTransducer(^id(id val) {
        return [class return:val];
    }));

    // Collect values in an array since each value passed to our transducer can generate more than
    // one value (for example when using the cat transducer).
    MOGReducer *reducer = transducerWithMapToRAC(MOGArrayReducer());

    return [[self bind:^{
        return ^(id value, BOOL *stop) {
            // Reduce the single value
            id acc = reducer.reduce(reducer.initial(), value);
            
            // Stop if the transducer signals that the reduction is done (could for example happen 
            // when using the take(n) transducer.
            if (MOGIsReduced(acc)) {
                *stop = YES;
                // Collect the final values from the process (for example when using partition).
                acc = reducer.complete(MOGReducedGetValue(acc));
            }
            return [class concat:acc];
        };
    }] setNameWithFormat:@"[%@] -transform:", self.name];
}

@end
```

This can later be used to apply a transducer to all values in a channel like this:

```objective-c
NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];
currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

MOGTransducer add100ToIntValuesAndFormatAsCurrency = MOGComposeArray(@[
    MOGFilterTransducer(StringIsValidInt()),
    MOGMapTransducer(^id(NSString *string) {
        return @([string intValue] + 100);
    }),
    MOGMapTransducer(^id(id val) {
        return [currencyFormatter stringFromNumber:val];
    })
]);

[[textField.rac_textSignal transform:add100ToIntValuesAndFormatAsCurrency] subscribeNext:^(id x) {
    NSLog(@"Number plus 100 = %@", x);
}];

```

The transducer can then be reused in any other transformation, and is not even tied to `RACStream`.


## Installation
The easiest way is to install through [Carthage](https://github.com/Carthage/Carthage). Simply add

```
github "mhallendal/MogKit" "master"
```

to your `Cartfile` and follow the Carthage instructions for including the framework in your application.

You can also add it as submodule to your project `https://github.com/mhallendal/MogKit.git` and include the project file in your application.

If you are using the Foundation extensions, like `-mog_transduce:` on `NSArray`, make sure that you add `-ObjC` to your application's _Other Linker Flags_.

CocoaPods support is planned.

## TODO
- Swift support (post 1.0)

## Status
The API is still not locked down so might change slightly until 1.0 has been released.
