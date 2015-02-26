# Example: Alpha trimmed mean filter
Here is an example that shows some of the reusability by creating processes that are agnostic to the underlying data structures or how the results are collected, a reusable _alpha trimmed mean filter_:

```objective-c
MOGTransducer TrimTransducer(NSUInteger drop, NSUInteger finalSize)
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

MOGMapFunc TrimArray(NSUInteger trimN)
{
    return ^id(NSArray *values) {
        return [values mog_transduce:TrimTransducer(trimN, values.count - 2 * trimN)];
    };
}

MOGMapFunc MeanOfArrayOfNumbers()
{
    return ^id(NSArray *numbers) {
        return [numbers valueForKeyPath:@"@avg.self"];
    };
}

MOGTransducer AlphaTrimmedMeanFilter(NSUInteger windowSize)
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
MOGReducer *manualFilter = filter(MOGLastValueReducer());

// Can compare the values of number with the result array above.
number = manualFilter.reduce(nil, @14); // number == 14
number = manualFilter.reduce(nil, @13); // number == 14
number = manualFilter.reduce(nil, @12); // number == 14
number = manualFilter.reduce(nil, @1);  // number == 14
number = manualFilter.reduce(nil, @2);  // number == 13.83
```
