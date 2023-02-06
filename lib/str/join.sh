# Joins the FIELDs using SEP.
# Usage: join SEP [FIELD ...]

case $#
in
	# fill argv to make this snippet set -e -u safe
	(0) set -- '' '' ;;
	(1) set -- "$@" '' ;;
esac

_sep=$1
shift

for _a
do
	set -- "$@" "${_sep}" "$1"
	shift
done
unset _a _sep

shift  # shift away first sep
(IFS=''; printf '%s\n' "$*")
