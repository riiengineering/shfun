# Joins the FIELDs using SEP.
# Usage: join SEP [FIELD ...]

case $#
in
	# fill argv to make this snippet set -e -u safe
	(0) set -- '' '' ;;
	(1) set -- "$@" '' ;;
esac

__strjoin_sep=$1
printf '%s' "$2"
shift 2

while ! eval "${1+!} :"
do
	printf '%s%s' "${__strjoin_sep}" "$1"
	shift
done
printf '\n'

unset -v __strjoin_sep
