# Removes empty lines, leading and trailing whitespace from stdin or argv.
# Usage:
#  - trim ' lorem ipsum'
#  - echo 'lorem ipsum ' | trim

case $#
in
	(0) cat - ;;
	([0-9]*) printf '%s\n' "$*" ;;
esac \
| sed \
	-e 's/^[[:space:]]*//' \
	-e 's/[[:space:]]*$//' \
	-e '/^[[:space:]]*$/d'
