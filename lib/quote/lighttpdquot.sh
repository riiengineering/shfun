# Quotes all arguments into a single lighttpd config-style string.
#
# Usage:
#  - lighttpdquot foo bar baz
#  - lighttpdquot 'foo bar baz'

sed \
	-e ':a' -e '$!N' -e '$!b a' \
	-e 's/\\/\\\\/g' \
	-e 's/\n/\\n/g' \
	-e 's/"/\\"/g' \
	-e 's/\r/\\r/g' \
	-e 's/	/\\t/g' \
	-e '$s/^/e"/' -e '$s/$/"/' <<EOF
$*
EOF
