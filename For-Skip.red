Red [
	Title: "For-Skip"
	Description: "Loop code on records"
	Author: "Giuseppe Chillemi"
	date: 28/01/2025
	Copyright: "To be choosen"

]


for-skip: func [
	"Run a code skipping value"
	'target [word!]
	skip
	code
	/at
	pos
	;/local
] [
	until [
		do code
		set target system/words/skip get target skip
		tail? get target 
	]
]


