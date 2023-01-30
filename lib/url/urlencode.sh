# set the locale to C so that the input string can be indexed by byte
# in multi-byte locales, substr() will not index by byte but by character, instead.
LC_ALL=C awk '
BEGIN {
	# pre-calculate lookup table
	for (i = 1;i < 256; ++i)
		ord[sprintf("%c", i)] = i
}
NR > 1 {
	printf "%%%02X", ord[ORS]
}
{
	for(i = 1; i <= length; ++i) {
		c = substr($0, i, 1)
		printf "%s", (c ~ /[0-9A-Za-z.~_-]/) ? c : sprintf("%%%02X", ord[c])
	}
}
END {
	printf "%s", ORS
}
' <<EOF
$*
EOF
