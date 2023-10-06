random_short() {
	__RANDOM_SEED=$(
		awk -v min=0 -v max=32768 -v seed="${__RANDOM_SEED-}" '
		BEGIN {
			if (seed) {
				srand(seed)
			} else {
				srand()
			}

			print int(min + rand() * (max - min + 1))
		}')
	export __RANDOM_SEED

	echo $((__RANDOM_SEED))
}

random_string() {
	# usage: random_string [length] [character classes]

	# silence stderr to suppress "/usr/bin/tr: write error: Broken pipe" in GitHub actions
	{
		LC_ALL=C @tr -dc "${2-'[:print:]'}" </dev/urandom \
		| @dd bs=1 count=${1-128}
	} 2>/dev/null
}
