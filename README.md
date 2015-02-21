# MogKit

MogKit is a toolkit that makes heavy use of _Transducers_ in order to create composable transformations that are independent from the underlying context they are working on.

For an introduction to transducers, see [Clojure - Transducers](http://clojure.org/transducers) and the presentation by Clojure creator [Rich Hickey](https://www.youtube.com/watch?v=6mTbuzafcII).

## Use cases
There are several cases where using MogKit might make sense. The easiest is when you simply want to transform some data in for example an array into a new array.

```objective-c
NSArray *array = @[@1, @2, @3];
NSArray *result = [array mog_transduce:MOGMapTransducer(^id(NSNumber *number) {
    return @(number.intValue + 100);
});

// result is now @[@101, @102, @103]
```

Another cases is when you have some data structure and you want to add a functional API to it, for example extending `NSArray`. In order to for example add a `filter` function to array, all you need to do is

```objective-c
@implementation NSArray (Filterable)

- (NSArray *)my_filter:(MOGPredicate)predicate
{
    return [MOGTransduce(self, MOGMutableArrayAppendReducer(), [NSMutableArray new], MOGFilterTransducer(predicate) copy];
}

@end
```

Using MogKit isn't limited to containers implementing `NSFastEnumeration`. You can easily make use of it to add composable transformation to anything where you want to transform a set of values. Here is an example adding a `-transform:` method to `RACStream` in order to apply the passed in transducer to all values on the stream. This can be used instead of chaining a several of RACStreams built in transformations.

```objective-c
@implementation RACStream (MogKit)

- (instancetype)transform:(MOGTransducer)transducer
{
    MOGReducer reducer = transducer(MOGLastValueReducer());

    Class class = self.class;

    return [[self flattenMap:^RACStream *(id value) {
        id transformed = reducer(nil, value);
        if (transformed) {
            return [class return:transformed];
        } else {
            return class.empty;
        }
    }] setNameWithFormat:@"[%@] -transform:", self.name];
}

@end

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

[[self.textField.rac_textSignal transform:add100ToIntValuesAndFormatAsCurrency] subscribeNext:^(id x) {
    NSLog(@"Number plus 100 = %@", x);
}];

```

The transducer can then be reused in any other transformation, and is not tied to `RACStream`.

## Example: Alpha trimmed mean
A simple map operation on an array

```objective-c
NSArray *array = @[@1, @2, @3];
NSArray *result = [array mog_transduce:MOGMapTransducer(^id(NSNumber *number) {
    return @(number.intValue + 100);
});

// result is now @[@101, @102, @103]
```

What is nice about using transducers here is that they are composable and agnostic about both input source and output. This means that it's easy to create reusable processes that can be used in many different examples.

```objective-c
MOGTransducer uppercaseLongNames = MOGCompose(MOGFilterTransducer(^BOOL(NSString *str) {
    return str.length >= 5;
}), MOGMapTransducer(^id(NSString *str) {
    return [str uppercaseString];
}));

NSArray *uppercasedAndLong = [@[@"Joe", @"Sandra", @"steve", @"al"] mog_transduce:uppercaseLongNames]);
// uppercasedAndLong == @[@"SANDRA", @"STEVE"]
```

Since transducers work by compositing rather then chaining it means that the input values are only iterated over once and not one time per operation.

Here is an example that shows some of the reusability by creating processes that are agnostic to the underlying data structures or how the results are collected, a reusable _alpha trimmed mean filter_:

```objective-c
MOGTransducer TrimTransducer(int drop, int finalSize)
{
    return MOGCompose(MOGDropTransducer(drop), MOGTakeTransducer(finalSize));
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
        return [values mog_transduce:TrimTransducer(trimN, (int)values.count - 2 * trimN)];
    };
}

MOGMapFunc MeanOfArrayOfNumbers()
{
    return ^id(NSArray *numbers) {
        return [numbers valueForKeyPath:@"@avg.self"];
    };
}

MOGTransducer AlphaTrimmedMeanFilter(int windowSize)
{
    return MOGComposeArray(@[
        MOGWindowTransducer(windowSize),
        MOGMapTransducer(SortArrayOfNumbers(YES)),
        MOGMapTransducer(TrimArray(windowSize / 4)),
        MOGMapTransducer(MeanOfArrayOfNumbers())
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
MOGReducer manualFilter = filter(MOGLastValueReducer());

// Can compare the values of number with the result array above.
number = manualFilter(nil, @14); // number == 14
number = manualFilter(nil, @13); // number == 14
number = manualFilter(nil, @12); // number == 14
number = manualFilter(nil, @1);  // number == 14
number = manualFilter(nil, @2);  // number == 13.83
```

## Installation
The easiest way is to install through [Carthage](https://github.com/Carthage/Carthage). Simply add

```
github "mhallendal/MogKit" "master"
```

to your `Cartfile` and follow the Carthage instructions for including the framework in your application.

You can also add it as submodule to your project `https://github.com/mhallendal/MogKit.git` and include the project file in your application.

If you are using the Foundation extensions, like `-mog_transduce:` on `NSArray`, make sure that you add `-ObjC` to your application's _Other Linker Flags_.

CocoaPods support is planned.

## Swift support?
It's coming.
