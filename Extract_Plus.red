Red [
	Title: "Extract+"
	Description: "DSL for extracting data from blocks and build new rows"
	Author: "Giuseppe Chillemi"
	date: 30/01/2025
	Copyright: "To be choosen"
	Todo: {
		column datatype verification
		Auxiliary code
		* Filtering
		Review code filtering arguments
	}
	Version: 2.0
	Log: {
		Added row filtering
		Avoid recreting the columns context (row-proto is actually static)
		Avoid recreating "to-delete" (It is static too)
	}
	Notes: {
		Introduction: https://matrix.to/#/!vizjfgYzCOUHBNcXdY:gitter.im/$43xXyf_uOOpiuQgCVwXffHtDCKHKLpvX9QUPmr-XMp0?via=gitter.im&via=matrix.org&via=tchncs.de
	}
]

#include %for-skip.red
#include %quoty.red

extract+: func [
	"Extract replacement with DSL"
	data [block!] "The data with rows of fixed size"
	skip-size [integer!] "Size of each row"
	row-proto [block!] "ROW proto with DSL" 
	/where
	where-before
	where-after
	/local
	;--- Use by forall, can't be removed	
	to-delete					;The positions to delete
	
	row								;Final data Row
	row-proto-copy		;Copy of the row-proto argument
	ctx								;Context containing words and columns
	ctx-proto					
	ctx-usr						;the context with temporary elements
	ctx-temp
	do-not-pick?
	proto-created?
	keep?
	ln

	;---Parse variables, can't be removed and put in context, only synced
	pos
	code
	value
	s									; Used to debug position

	
	out-data

] [

	;--- TBD:
		;TBD: standard extract mode
		
	;--- code ideas:	
		;custom parse?
		;POST-ROW; Pre row manipulation code - Return "SKIP = skip current row"
		;PRE-ROW; Post row manipulation code - Return "SKIP = skip current row"
		;INIT; init code before starting everything
		;FIELD-CODE: (Code at each field?)		

		
	if skip-size < 1 [do make error! "row Size less than 1"]
	ln: 0
	to-delete: copy []
	row-proto-copy: copy row-proto
	out-data: copy []
	ctx-proto: copy []
	proto-created?: false
	keep?: true
	
	ctx-temp: make object! [
		ctx-usr: make object! [
			data: 						;data at current position
			row:
			row-proto:				;the user base prototype row
			row-proto-copy:		;The current copy of the proto
			ctx-proto: 				;The context prototype with all the words. Available in final stage
			ctx:							;The created context after reduce
			to-delete: none 	;the fields to delete
;---- Candidate data -------------------------------
;			unreduced-row: ;the unreduced row
;			reduced-row: ;The row after reducing
;			current-position: ;The data at the current pparsing position
;			total-row-processed: ;All the processed rows, including skipped
;			row-processed: ;The nuber of rows processed
;			row-skipped: ;the number of skipped row
;			row-to-go: ;the number of rows to go
;			pre-proto: ;Code to use before the prototype

		]
	]
	
	ctx-usr: ctx-temp/ctx-usr
		
	case [
		where [
			bind where-before ctx-temp
			bind where-after ctx-temp
		]
	]
			
	for-skip data skip-size [
		
		ctx-usr/data: data
		
		if where [
			keep?: attempt [do where-before]
			if none? keep? [do make error! "Where-Before code failed!: "]
		] 
		
		if keep? [
			parse row-proto-copy [

				any [
				
					'quote any-type! (ln: ln + 1)
					
				|

					opt [remove #no (do-not-pick?: true)]
					any [not if (proto-created?) set key set-word! (append ctx-proto key) | set-word!]
					
					change only [
						[set pos integer! | set code paren!]
						(either do-not-pick? [ln: ln + 1 if not proto-created? [append to-delete ln]] [ln: ln + 1])					
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
			either not proto-created? [
				if (length? unique ctx-proto) <> length? ctx-proto [do make error! rejoin ["Duplicated set-words!" mold ctx-proto]]		
				ctx: make object! append ctx-proto none
				proto-created?: true
				ctx-usr/data: ctx

			] [
				set ctx none
			]
			
			bind row-proto-copy ctx
			row: reduce row-proto-copy 
			forall to-delete [
				remove at row to-delete/1
			]

			
			either where [
				ctx-usr/row: row
				keep?: attempt [do where-after]
				case [
					none? keep? [do make error! "Where-after code failed!: "]
					keep? = true [append out-data row]
				]
				keep?: none
			] [
				append out-data row			
			]
			
			row-proto-copy: copy row-proto
		]
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
	data: [a b #[aa: 22] d e f]; a1 a2 #[aa: 44] a4 a5 a6]
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

#assert [
	series: [
		a1 b1 #[xx: 10 yy: 20] 
		a2 b2 #[xx: 30 yy: 40]
		a3 b3 #[xx: 50 yy: 60]
	]	
	[a1 10 a2 30 a3 50] = extract+ series 3 [quote 1 1 #no a: 3 (a/xx)]
	unset 'series
]

#ssert [
	series: [
		a1 b1 #[xx: 10 yy: 20] 
		a2 b2 #[xx: 30 yy: 40]
		a3 b3 #[xx: 50 yy: 60]
	]
	[1 a1 10] = extract+/where series 3 [quote 1 1 #no a: 3 (a/xx)] [
		either ctx-usr/data/1 = 'a2 [false] [true]
	] 
	[
		either ctx-usr/row/3 = 50 [false] [true]
	]
	unset 'series
]
