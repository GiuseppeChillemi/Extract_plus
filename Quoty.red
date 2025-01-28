Red [
	Title: "Quoty"
	Description: "Quotes values for reducing"
	Author: "Giuseppe Chillemi"
	date: 28/01/2025
	Copyright: "To be choosen"

]


quoty: func [
	"Quotes for to make an object proto"
	val [any-type!]
	;/object!
	;/map!
] [
	case [
		word? :val [to-lit-word :val]
		lit-word? :val [reduce ['quote  to-lit-word :val]]
		path? :val [to-lit-path :val]
		lit-path? :val [reduce ['quote :val]]
		any-function? :val [reduce ['quote :val]]
		;block? :val [reduce [:val]] <- Needed for APPEND without /only
		true [:val]
	]
]


