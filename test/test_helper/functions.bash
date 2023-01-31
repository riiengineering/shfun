isolated_path() {
	# usage: isolated_path [command...]
	# returns: value to set for $PATH
	_bdir=$(mktemp -d "${BATS_TEST_TMPDIR:?}/bin.XXXXXX")
	printf '%s\n' "${_bdir}"
	for _b
	do
		_s=$(command -v "${_b}") || {
			printf '%s: command not found (will be missing in isolated PATH)' \
				"${_b}" >&2
			continue
		}
		ln -s "${_s}" "${_bdir:?}/"
	done
	unset _bdir _b _s
}

random_string() {
	# usage: random_string [length] [character classes]
	LC_ALL=C tr -dc "${2-'[:print:]'}" </dev/urandom \
	| dd bs=1 count=${1-128} 2>/dev/null
}
