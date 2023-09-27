EnableSandbox() {
	SHFUN_SANDBOX_DIR=$(@mktemp -d "${SHELLSPEC_TMPDIR:?}/sandbox.XXXXXX")

	while test $# -gt 0
	do
		AllowExternalCommand "$1" || :
		shift
	done

	shellspec_before_all _ActivateSandbox
}

_ActivateSandbox() {
	PATH="${SHELLSPEC_MOCK_BINDIR:?}:${SHELLSPEC_SUPPORT_BINDIR}:${SHFUN_SANDBOX_DIR:?}"
	readonly PATH
	export PATH
}

AllowExternalCommand() {
	# usage: AllowExternalCommand name_or_abspath

	case $1
	in
		(/*)
			ln -s "$1" "${SHFUN_SANDBOX_DIR:?}/${1##*/}"
			;;
		(*)
			__extcmd_path=$(command -v "$1") || {
				printf '%s: command not found (will be missing in sandbox)' \
					"$1" >&2
				return 1
			}

			ln -s "${__extcmd_path}" "${SHFUN_SANDBOX_DIR:?}/${1}"
			;;
	esac
}
