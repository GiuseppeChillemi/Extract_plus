## Extract+

It is your first army knife to process your data!

The principle is simple: instead of providing an additional column position to extract, pass a block rapresenting the target new ROW, where you can express multiple columns taken from the source, process and transform the data using a simple DLS



Example:

```
series: [a1 b1 c1 a2 b2 c2 a3 b3 c3]
extract+ series 3 [1 3]
```

This will produce:

```
[a1 c1 a2 c2 a3 c3]
```

But the principle is different from regular `extract`. While with it you can provide only columns, here you can provide different data to build each row.

The command:

```
extract+ series 3 [1 "Red" 3]
```

Will create:

```
[a1 "Red" c1 a2 "Red" c2 a3 "Red" c3]
```

This is already a great change, letting you mix original values with new ones but it does not end here.

The DSL accepts `set-word!` to assign the column, and you can use it to reference the data:

```
extract+ series 3 [a: 1 3 (rejoin ["Column value: " a])]
```

Result

```
[
	a1 c1 "Column value: a1" 
	a2 c2 "Column value: a2" 
	a3 c3 "Column value: a3"
]
```

Now let's do some more challeging: get values from a container



```
series: [
	a1 b1 #[x: 10 y: 20] 
	a2 b2 #[x: 30 y: 40]
	a3 b3 #[x: 50 y: 60]
]

```

We want the first colunm ad `X` value from the map:

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