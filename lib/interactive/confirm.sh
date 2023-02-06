printf '%s' "${1-Confirm?}"
case $2
in
	(y) printf ' [Y/n] ' ;;
	(n) printf ' [y/N] ' ;;
	(*)
		printf ' [y/n] '
		set -- "$1"  # unset default
	;;
esac

while :
do
	read -r __confirm_resp
	case ${__confirm_resp:-"${2-}"}
	in
		([Yy]|[Yy][Ee][Ss])
			exit 0 ;;
		([Nn]|[Nn][Oo])
			exit 1 ;;
		(*)
			printf 'Please respond with "yes" or "no": ' ;;
	esac
done
