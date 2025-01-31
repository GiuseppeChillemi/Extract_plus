# Introduction

## Why Extract+ ?

Red has a nice instrument to get columns of elements in a block and it is the `extract` command.  With it, you can process a block as a list of rows. The syntax of the commmand is:

```
EXTRACT series width
```

An example of the command is:

```
series: [
	a1 b1 c1 
	a2 b2 c2 
	a3 b3 c3
]
extract series 3
```

Result:

```
[a1 a2 a3]
```

The command let you select a different column that the first one with the `/index`refinement

```
extract/index series 3 2
```

Will result in:

```
[b1 b2 b3]
```

You can't do anything else and this limits the coder a lot, as to have multiple columns is forced to use `foreach` loops, `foreach` + `compose/reduce`. 

##### So `EXTRACT+` has born!

# Extract+

It is your Swiss Army knife to process your data!

The principle is simple: instead of providing an additional column position to extract, use a `block` rappresenting the target new ROW with a descriptive DSL. Its syntax is simple: you can express multiple source columns as `integer!`, use `set-words` to mark source columns and transform later the data using code in paren.

## Basic Usage

Example:

```
series: [
	a1 b1 c1 
	a2 b2 c2 
	a3 b3 c3
]
extract+ series 3 [1 3]
```

This will produce:

```
[
	a1 c1 
	a2 c2 
	a3 c3
]
```

But the principle is different from regular `extract`. While with it you can provide only columns, you can provide different data to `extract+` for building each row.

The command:

```
extract+ series 3 [1 "Red" 3]
```

Will create:

```
[
	a1 "Red" c1 
	a2 "Red" c2 
	a3 "Red" c3
]
```

This is already a great change, letting you mix original values with new ones but it does not end here.

## Assigning set-words

The DSL accepts `set-word!` to assign the column, and you can use it to reference the data. An isolated context is created:

```
extract+ series 3 [a: 1 3 (rejoin ["Column value: " a])]
```

Using the same source data as before, the third column is CALCULATED

Result:

```
[
	a1 c1 "Column value: a1" 
	a2 c2 "Column value: a2" 
	a3 c3 "Column value: a3"
]
```

Now let's do some more challeging: getting values from a container

```
series: [
	a1 b1 #[xx: 10 y: 20] 
	a2 b2 #[xx: 30 y: 40]
	a3 b3 #[xx: 50 y: 60]
]

```

We want the first colunm ad `XX` value from the map:

```
extract+ series 3 [1 #no a: 3 (a/xx)]
```

Result:

```
[
	a1 10 
	a2 30 
	a3 50
]
```

Please note the `#no` keyword that instructs the DSL to not use the column 3 in the row but just for setting `a`



## Auto quoting:

If the following elements are found in the row description, they will be automatically quoted:

* `Word!`
* `Lit-Word`
* `Path!`
* `Lit-Path!`
* `Function!`



## Quoting DSL elements

`Paren!`

`Set-Word!`

`#no` keyword

`integer!`s 



As they are part of the DSL, they must be preceded by `QUOTE` to be used

```
series: [
	a1 b1 #[xx: 10 y: 20] 
	a2 b2 #[xx: 30 y: 40]
	a3 b3 #[xx: 50 y: 60]
]
```

This row:

```
extract+ series 3 [quote 1 1 #no a: 3 (a/xx)]
```

Generates

```
[
	1 a1 10 
	1 a2 30 
	1 a3 50
]
```

You can do the same with the `#no` keyword and any further keyword of the DSL

## Filtering

Filtering has been implemented using a `/before` and `/after` refinements

You  could provide 2 code blocks as argument, one for each:

`where-before`

`where-after`

They can access the `CTX-USER` context where some internal elements are available to your code.

`DATA` is the row at current position. You can use it to access it and do you test. If you return `true` as last element, the data will be processed, otherwise `false` will skip to the next row.  It's content is valid either on `where-before` but also on`where-after` 

`ROW` is valid only on `where-after` and represents the data row created by the dialect, an instant before writing it to the final container. As before, returning `true` it will be accepted, otherwhise `false` will skip it.

An example usage:

``` 
series: [
    a1 b1 #[xx: 10 yy: 20] 
    a2 b2 #[xx: 30 yy: 40]
    a3 b3 #[xx: 50 yy: 60]
]

extract+/before/after series 3 [quote 1 1 #no a: 3 (a/xx)] [
    either ctx-usr/data/1 = 'a2 [false] [true]
] 
[
    either ctx-usr/row/3 = 50 [false] [true]
]
```

This code will produce:

```
[1 a1 10]
```

This code will skip rows where the starting column `1` content is `a2` and final row column `3` value is `50`

### Columns binding

Is `/after` refinement is active, binds the `where-after` block to the columns context. You will be able to access all the elements you have assigned a letter, even those with the `#no` keyword



```
series: [
    a1 b1 #[xx: 10 yy: 20] 
    a2 b2 #[xx: 30 yy: 40]
    a3 b3 #[xx: 50 yy: 60]
]
extract+/before/after series 3 [quote 1 1 #no a: 3 b: (a/xx)] [
    either ctx-usr/data/1 = 'a2 [false] [true] 
] 
[
    either all [a = #[xx: 50 yy: 60] b = 50] [false] [true]
]
```



The second code block (`where-after`) has access to the columns defined in the proto. So even if column 3 is not present in the final row, it could be accessed using the `a` word and checked, gaining access to the original `map!` values. Also, with `b` you will have access to the computed code `(a/xx)` result.

So when `a = #[xx: 50 yy: 60]` and `b = 50` then row will be filtered out from the result as the code is: `either all [a = #[xx: 50 yy: 60] b = 50] [false] [true]`

As there is a `where-before` condition, which is triggered in the second row  `either ctx-usr/data/1 = 'a2 [false] [true] `, the final result will include only 1 row:

`[1 a1 10]`

This example has negative filtering focus. If you want to include elements, simply switch `true` and `false` position in the either blocks:

```
series: [
    a1 b1 #[xx: 10 yy: 20] 
    a2 b2 #[xx: 30 yy: 40]
    a3 b3 #[xx: 50 yy: 60]
]
[1 a1 10] = extract+/after series 3 [quote 1 1 #no a: 3 b: (a/xx)] [
    either all [a = #[xx: 50 yy: 60] b = 50] [true] [false] 
]
```

Result:

```
[1 a3 50]
```

As only the third row has all the requisites in `all` block to return true.



### CTX-USER

(to be written)

## Support functions

Actually the code relies on:

`for-skip` and `quoty` functions included in the repository. 

# ToBeDone:

* Filtering data based on source and built row (DONE)

* Init code

* Better documentation

* More tests and examples

* In-Row Sub series creation

* External Sub series creation

* Commenting

   

  





