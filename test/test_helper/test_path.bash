shell_path() {
	if test -e "${SHELL-}"
	then
		printf '%s\n' "${SHELL}"
	else
		command -v "${SHELL-sh}"
	fi
}

prepare_test_path() {
	# usage: prepare_test_path
	# adjusts the $PATH variable accordingly
	: "${BATS_FILE_TMPDIR:?}"

	if test -d "${BATS_FILE_TMPDIR:?}/bin" 
	then
		rm -r "${BATS_FILE_TMPDIR:?}/bin"
	fi

	mkdir "${BATS_FILE_TMPDIR:?}/bin"
	PATH="${BATS_FILE_TMPDIR:?}/bin${PATH:+:}${PATH-}"
	export PATH
}

install_test_script() {
	_script_dest="${BATS_FILE_TMPDIR:?}/bin/${1:?}"
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
			_script_interp=$(shell_path) ;;
	esac	
	printf '#!%s\n' "${_script_interp:-/bin/sh}" >"${_script_dest:?}"
	cat "${2:?}" >>"${_script_dest:?}"
	chmod 0700 "${_script_dest:?}"
	unset _script_dest _script_interp
}