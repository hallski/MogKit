# MogKit
[![Build Status](https://travis-ci.org/mhallendal/MogKit.svg?branch=master)](https://travis-ci.org/mhallendal/MogKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pod Information](https://img.shields.io/cocoapods/v/MogKit.svg?style=flat)](http://cocoadocs.org/docsets/MogKit)

MogKit is a toolkit that provides fully tested and easily composable transformations to collections and any series of values (like signals, channels, etc). The transformations are independant of the underlying values or data structures which makes them highly reusable.

As opposed to similar transformation frameworks MogKit works with composition instead of chaining which means the values are only iterated over once instead of once per step.

## Use cases
There are several cases where using MogKit might make sense. Easiest shown with some example.

### Simply transform data
When you simply want to transform some data in for example an array into a new array.

```objective-c
NSArray *array = @[@1, @2, @3];
NSArray *result = [array mog_transform:MOGMap(^id(NSNumber *number) {
    return @(number.intValue + 100);
});

// result is now @[@101, @102, @103]
```

Or work on some numbers and output as a string:
```objective-c
NSArray *array = @[@1, @2, @3];

NSString *result = MOGTransform(array, MOGStringConcatReducer(@", "), [NSMutableString new], MOGCompose(MOGMap(^id(NSNumber *val) {
    return @(val.intValue + 10);
}), MOGMap(^id(NSNumber *val) {
    return val.stringValue;
})));

// result = "11, 12, 13"
```

It can also be used on any `NSObject` like:
```objective-c
id object = @10;
NSArray *expected = @[@(-10), @0, @10];

NSArray *result = [object mog_transform:MOGFlatMap(^id(NSNumber *number) {
    return @[@(-number.intValue), @0, number];
}) reducer:MOGArrayReducer() initial:[NSMutableArray new]];

// result = @[@(-10), @0, @10]
```

### Use to easily implement some transformation functions
Another case is when you have some data structure and want to add a transformation method to it, for example extending `NSArray` and give it a `filter` method, all you need to do is

```objective-c
@implementation NSArray (Filterable)

- (NSArray *)filter:(MOGPredicate)predicate
{
    return [self mog_transform:MOGFilter(predicate)];
}

@end
```

### Combine to create new transformations
Say you want to add a `trim:` method to `NSArray` that returns a new array with `trimSize` elements removed from the start and end.
```objective-c
- (NSArray *)trim:(NSUInteger)trimSize 
{
    return [self mog_transform:MOGCompose(MOGDrop(trimSize), MOGTake(self.count - 2 * trimSize))];
}
```

### Non-collection use cases
Using MogKit isn't limited to containers implementing `NSFastEnumeration`. You can easily make use of it to add composable transformation to anything where you want to transform a set of values. Here is an example adding a `-mog_transform:` method to `RACStream` (from [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)) in order to apply the passed in transformation to all values on the stream. This can be used instead of chaining a several of RACStreams built in transformations.

```objective-c
@implementation RACStream (MogKit)

- (instancetype)mog_transform:(MOGTransformation)transformation
{
    Class class = self.class;

    MOGTransformation transformationWithMapToRAC = MOGCompose(transformation, MOGMap(^id(id val) {
        return [class return:val];
    }));

    MOGReducer reducer = transformationWithMapToRAC(MOGArrayReducer());

    return [[self bind:^{
        return ^(id value, BOOL *stop) {
            id acc = reducer([NSMutableArray new], value);

            if (MOGIsReduced(acc)) {
                *stop = YES;
                acc = MOGReducedGetValue(acc);
            }
            return [class concat:acc];
        };
    }] setNameWithFormat:@"[%@] -mog_transform:", self.name];
}

@end
```

This can later be used to apply a transformation to all values in a channel like this:

```objective-c
NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];
currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

MOGTransformation add100ToIntValuesAndFormatAsCurrency = MOGComposeArray(@[
    MOGFilter(StringIsValidInt()),
    MOGMap(^id(NSString *string) {
        return @([string intValue] + 100);
    }),
    MOGMap(^id(id val) {
        return [currencyFormatter stringFromNumber:val];
    })
]);

[[textField.rac_textSignal mog_transform:add100ToIntValuesAndFormatAsCurrency] subscribeNext:^(id x) {
    NSLog(@"Number plus 100 = %@", x);
}];

```

The transformation can then be reused and is not even tied to `RACStream`.

## Implemented Transformations
- Map
- Filter
- Remove
- Take
- TakeWhile
- TakeNth
- Drop
- DropWhile
- DropNil
- Replace
- ReplaceWithDefault
- MapDropNil
- Unique
- Dedupe
- Flatten
- FlatMap
- Window

## Installation

### Carthage
The easiest way is to install through [Carthage](https://github.com/Carthage/Carthage). Simply add

```
github "mhallendal/MogKit"
```

to your `Cartfile` and follow the Carthage instructions for including the framework in your application.

### CocoaPods
Alternatively by using CocoaPods, simply add
```
pod 'MogKit'
```

to your `Podfile`.

### Submodule
You can also add it as submodule to your project `https://github.com/mhallendal/MogKit.git` and include the project file in your application.

If you are using the Foundation extensions, like `-mog_transform:` on `NSArray`, make sure that you add `-ObjC` to your application's _Other Linker Flags_.

## TODO
- Swift support (post 1.0)

## Status
The API is still not locked down so might change slightly until 1.0 has been released.

## This looks like Transducers
For a reader that are familiar with Transducers this will feel familiar, MogKit is implemented using Transducers and `MOGTrasformation`s are actually transducers mapping from `MOGReducer` to `MOGReducer`.

For an [introduction to transducers](http://blog.cognitect.com/blog/2014/8/6/transducers-are-coming), see [Clojure - Transducers](http://clojure.org/transducers) and the presentation by Clojure creator [Rich Hickey](https://www.youtube.com/watch?v=6mTbuzafcII).
