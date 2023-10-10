SetupCommandFromFile() {
	# usage: SetupCommandFromFile command_name file_path

	_mock_dest="${SHELLSPEC_MOCK_BINDIR:?}/${1:?}"
	case ${2-}
	in
		(*.awk)
			_script_interp=$(command -v awk) &&
			_script_interp="${_script_interp} -f" ;;
		(*.bash)
			_script_interp=$(command -v bash) ;;
		(*.sed)
			_script_interp=$(command -v sed) &&
			_script_interp="${_script_interp} -f" ;;
		(*.sh)
			_script_interp=${SHELLSPEC_SHELL-} ;;
	esac
	@printf '#!%s\n' "${_script_interp:-/bin/sh}" >"${_mock_dest:?}"

	# leak detector hook
	printf 'case ${LEAK_DUMPFILE} in (?*) %s; %s ;; esac\n' \
		'set >"${LEAK_DUMPFILE}.cmdenter"' \
		"trap 'set -- \$?; set >\"\${LEAK_DUMPFILE}.cmdexit\"; exit \$1' EXIT" \
	>>"${_mock_dest:?}"

	# script
	@cat "${2:?}" >>"${_mock_dest:?}"

	@chmod +x "${_mock_dest:?}"

	unset -v _mock_dest _script_interp
}

SetupFunctionFromFile() {
	# usage: SetupFunctionFromFile func_name file_path
	case ${2-}
	in
		(*.bash|*.sh)
			eval "${1:?} () {
$(
	if @test -s "${2:?}"
	then
		@cat "${2:?}"
	else
		@printf ':\n'
	fi
)
}"
			;;
		(*)
			@printf 'invalid file extension for shell function code\n' >&2
			return 1
			;;
	esac
}

SetupCHelper() {
	have_cc || return 1

	"${_CC:?}" -std=c99 -o "${SHELLSPEC_MOCK_BINDIR}/${1:?}" "${2:?}"
}
