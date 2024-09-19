random_short() {
	__RANDOM_SEED=$(
		@awk -v min=0 -v max=32768 -v seed="${__RANDOM_SEED-}" '
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

pick_random_lines() {
	# usage: pick_random_lines [num|perc%] [file...]

	__random_lines_x=$1
	shift

	@awk -v x="${__random_lines_x}" -v seed="$(@date '+%M%S%H%d%y%m')" '
	BEGIN {
		srand(seed)  # use time of day as seed

		if (x ~ /%$/) {
			# percentage (likelyhood)
			low_limit = substr(x, 1, length(x)-1) / 100
			want_lines = 0
			min_lines = 1
		} else {
			# number
			low_limit = 0.33
			want_lines = (x + 0)
			min_lines = want_lines
		}
	}

	{
		if (num_results < min_lines) {
			RESULTS[++num_results] = $0
			next
		}

		r = rand()

		if (r < low_limit) {
			if (want_lines && num_results >= want_lines) {
				# we need an absolute numer of lines -> replace a random line
				RESULTS[int(r/low_limit*num_results) + 1] = $0

				# reduce the likelyhood of a replacement to achieve a better
				# mixture across the data set.
				# Without this adjustment the result will only ever contain
				# results from the end of the input(s).
				low_limit *= 0.95
			} else {
				RESULTS[++num_results] = $0
			}
		}
	}

	END {
		for (i = 1; i <= num_results; ++i) {
			print RESULTS[i]
		}
	}
	' "$@"
	unset -v __random_lines_x
}


# cache the C compiler path because sandboxes in specfiles make the C compiler
# undiscoverable later on
_find_cc() {
	case ${CC}
	in
		(/*)
			_CC="${CC}"
			;;
		(*/*)
			_CC="${PWD}/${CC}"
			;;
		(*)
			_CC=$(command -v "${CC:-cc}" 2>/dev/null) || return 1
			;;
	esac
	test -x "${_CC}"
}

_find_cc && __have_cc=0 || __have_cc=1

have_cc() {
	return $((__have_cc))
}

skip_c() {
	return $((! __have_cc))
}
