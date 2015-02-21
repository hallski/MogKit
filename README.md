# MogKit

MogKit is a toolkit that makes heavy use of _Transducers_ in order to create composable transformations that are independent from the underlying context they are working on.

Since transducers work by compositing rather then chaining it means that the input values are only iterated over once and not one time per operation.

For an introduction to transducers, see [Clojure - Transducers](http://clojure.org/transducers) and the presentation by Clojure creator [Rich Hickey](https://www.youtube.com/watch?v=6mTbuzafcII).

## Use cases
There are several cases where using MogKit might make sense. The easiest is when you simply want to transform some data in for example an array into a new array.

### Simply transform data
```objective-c
NSArray *array = @[@1, @2, @3];
NSArray *result = [array mog_transduce:MOGMapTransducer(^id(NSNumber *number) {
    return @(number.intValue + 100);
});

// result is now @[@101, @102, @103]
```

### Use to easily implement some transformation functions
Another cases is when you have some data structure and you want to add a functional API to it, for example extending `NSArray`. In order to for example add a `filter` function to array, all you need to do is

```objective-c
@implementation NSArray (Filterable)

- (NSArray *)my_filter:(MOGPredicate)predicate
{
    return [MOGTransduce(self, MOGMutableArrayAppendReducer(), [NSMutableArray new], MOGFilterTransducer(predicate) copy];
}

@end
```

### Combine to create new transformations
```objective-c
MOGTransducer TrimTransducer(int drop, int finalSize)
{
    return MOGCompose(MOGDropTransducer(drop), MOGTakeTransducer(finalSize));
}

// Used with an NSArray this could add an extension to the array with
- trim:(int)trimSize 
{
    return [[self mog_transduce:TrimTransducer(trimSize, self.count - 2 * trimSize)] copy];
}
```

### Non-collection use cases
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

## Swift support?
It's coming.
