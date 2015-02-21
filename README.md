# MogKit

MogKit is a toolkit that makes heavy use of _Transducers_ in order to create composable transformations that are independent from the underlying context they are working on.

For an introduction to transducers, see [Clojure - Transducers](http://clojure.org/transducers) and the presentation by Clojure creator [Rich Hickey](https://www.youtube.com/watch?v=6mTbuzafcII).

## Example
A simple map operation on an array

```objective-c
NSArray *array = @[@1, @2, @3];
NSArray *result = [array mog_transduce:MOGMap(^id(NSNumber *number) {
    return @(number.intValue + 100);
});

// result is now @[@101, @102, @103]
```

What is nice about using transducers here is that they are composable and agnostic about both input source and output. This means that it's easy to create reusable processes that can be used in many different examples.

Here is an example that creates an alpha trimmed mean average filter:

```objective-c
MOGTransducer TKTrim(int drop, int finalSize)
{
    return MOGCompose(MOGTake(finalSize), MOGDrop(drop));
}

MOGMapFunc SortArrayOfNumbers(BOOL ascending)
{
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:ascending];

    return ^id(NSArray *numbers) {
        return [numbers sortedArrayUsingDescriptors:@[lowestToHighest]];
    };
}

MOGMapFunc TrimArray(int trimN)
{
    return ^id(NSArray *values) {
        return [values mog_transduce:TKTrim(trimN, (int)values.count - trimN)];
    };
}

MOGMapFunc AvarageOfArrayOfNumbers()
{
    return ^id(NSArray *numbers) {
        return [numbers valueForKeyPath:@"@avg.self"];
    };
}

MOGTransducer AlphaTrimmedMeanFilter(int windowSize)
{
    return MOGComposeArray(@[
                             MOGWindow(windowSize),
                             MOGMap(SortArrayOfNumbers(YES)),
                             MOGMap(TrimArray(windowSize / 4)),
                             MOGMap(AvarageOfArrayOfNumbers())
                             ]);
}

// This filter can now be used in a number of different ways

NSArray *array = @[@14, @13, @12, @1, @2, @3, @4, @5, @15, @9, @8, @7, @13, @14];

MOGTransducer filter = AlphaTrimmedMeanFilter(12);

NSArray *result = [array mog_transduce:filter];
// result == [14, 14, 14, 14, 13.83, 13.5, 11.83, 10.33, 10.33, 9.5, 8.5, 7.5, 7.5, 7.5]

// By using a different reduce function it's easy to only get the last value:
NSNumber *number = MOGTransduce(array, MOGLastValueReducer(), @0, filter);
// number == 7.5

// Or we can simulate the numbers coming in from a stream and manually feed numbers to the filter.
MOGReducer filterReducer = filter(MOGLastValueReducer());

for (NSNumber *n in array) {
    number = filterReducer(nil, n);
}
// number == 7.5
```

## Installation
The easiest way is to install through [Carthage](https://github.com/Carthage/Carthage). Simply add

```
github "mhallendal/MogKit" "master"
```

to your `Cartfile` and follow the Carthage instructions for including the framework in your application.

You can also add it as submodule to your project `https://github.com/mhallendal/MogKit.git` and include the project file in your application.

If you are using the Foundation extensions, like `-mog_transduce:` on `NSArray`, make suer that you add `-ObjC` to your applications _Other Linker Flags_.

CocoaPods support is planned.

## Swift support?
It's coming.
