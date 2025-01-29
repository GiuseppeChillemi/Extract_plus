Red [
	Title: "Extract+"
	Description: "DSL for extracting data from blocks and build new rows"
	Author: "Giuseppe Chillemi"
	date: 28/01/2025
	Copyright: "To be choosen"
	Todo: {
		column datatype verification
		Auxiliary code
		Filtering
	}
]

#include %for-skip.red
#include %quoty.red

extract+: func [
	"Extract replacement with DSL"
	data [block!] "The data with rows of fixed size"
	skip-size [integer!] "Size of each row"
	row-proto [block!] "ROW proto with DSL"
	/local
	to-delete
	row
	row-proto-copy
	idx
	ctx
	ctx-proto
	do-not-pick?
	ln
	value
	s
	out-data
] [

		
	if skip-size < 1 [do make error! "row Size less than 1"]
	ln: 0
	to-delete: copy []
	row-proto-copy: copy row-proto
	out-data: copy []
	ctx-proto: copy []
	
	for-skip data skip-size [
		
		parse row-proto-copy [

				any [
					
					'quote any-type! (ln: ln + 1)
					
			|

					opt [remove #no (do-not-pick?: true)]
					any [set key set-word! (append ctx-proto key)] 
					
					change only [
						[set pos integer! | set code paren!]
						(either do-not-pick? [ln: ln + 1 append to-delete ln] [ln: ln + 1])					
					]
					
					(case [pos [quoty pick data pos] code [quoty code]])
					(pos: code: none do-not-pick?: false)

			|
			
					change only set value [word! | lit-word! | path! | get-path! | any-function! ] (quoty :value) (ln: ln + 1)
			
			|

				skip (ln: ln + 1)

			]
		
			end
		]
		
		
		ln: 0
		if (length? unique ctx-proto) <> length? ctx-proto [do make error! rejoin ["Duplicated set-words!" mold ctx-proto]]
		
		ctx: make object! append ctx-proto none
		bind row-proto-copy ctx
		row: reduce row-proto-copy 
		forall to-delete [
			remove at row to-delete/1
		]		
		append out-data row
		
		row-proto-copy: copy row-proto
		ctx-proto: copy []
		to-delete: copy []
	]
	out-data
]

#assert [
	data: [a b c d e f a1 b1 c1 d1 e1 f1]
	proto: [a: 1 3 b: (make map! compose [b: (a)]) quote xx: hello/word print]

	[	
		a c #[b: a] xx: hello/word print 
		a1 c1 #[b: a1] xx: hello/word print
	] = extract+ data 6 proto
	unset 'proto
	unset 'data
]

#assert [
	data: [a b #[aa: 22] d e f]
	proto: ["hi"  #no x: 3 (1 + 1)]
	["hi" 2] = extract+ data 6 proto
	unset 'proto
	unset 'data
]	
	
#assert [
	series: [a1 b1 c1 a2 b2 c2 a3 b3 c3]
	[a1 c1 a2 c2 a3 c3] = extract+ series 3 [1 3]
	unset 'series
]
	

#assert [
	series: [a1 b1 c1 a2 b2 c2 a3 b3 c3]
	[
		a1 c1 "Column value: a1" 
		a2 c2 "Column value: a2" 
		a3 c3 "Column value: a3"
	] = extract+ series 3 [a: 1 3 (rejoin ["Column value: " a])]
	unset 'series
]

#assert [
	series: [
		a1 b1 #[xx: 10 yy: 20] 
		a2 b2 #[xx: 30 yy: 40]
		a3 b3 #[xx: 50 yy: 60]
	]	
	[a1 10 a2 30 a3 50] = extract+ series 3 [1 #no a: 3 (a/xx)]
	unset 'series
]


