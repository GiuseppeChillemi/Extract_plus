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



## Support functions

Actually the code relies on:

`for-skip` and `quoty` functions included in the repository. 

# ToBeDone:

* Filtering data based on source and built row

* Init code

* Pre/post row code

* Better documentation

* More tests and examples

  





