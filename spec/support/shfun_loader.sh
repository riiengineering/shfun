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
	printf '#!%s\n' "${_script_interp:-/bin/sh}" >"${_mock_dest:?}"
	cat "${2:?}" >>"${_mock_dest:?}"
	chmod +x "${_mock_dest:?}"

	unset -v _mock_dest _script_interp

}

SetupFunctionFromFile() {
	# usage: SetupFunctionFromFile func_name file_path
	case ${2-}
	in
		(*.bash|*.sh)
			eval "${1:?} () {
$(
	if test -s "${2:?}"
	then
		cat "${2:?}"
	else
		echo ':'
	fi
)
}"
			;;
		(*)
			echo 'invalid file extension for shell function code' >&2
			return 1
			;;
	esac
}
