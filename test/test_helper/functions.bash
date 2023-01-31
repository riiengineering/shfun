random_string() {
	# usage: random_string [length] [character classes]
	LC_ALL=C tr -dc "${2-'[:print:]'}" </dev/urandom \
	| dd bs=1 count=${1-128} 2>/dev/null
}
