# set the locale to C so that the input string can be indexed by byte
# in multi-byte locales, substr() will not index by byte but by character, instead.
LC_ALL=C awk '
{
	while (p = index($0, "%")) {
		printf "%s%c", substr($0, 1, p-1), int("0x" substr($0, p+1, 2))
		$0 = substr($0, p+3)
	}
	printf "%s", $0
}
END {
	printf "%s", ORS
}
' <<EOF
$*
EOF
