# set the locale to C so that the input string can be indexed by byte
# in multi-byte locales, substr() will not index by byte but by character, instead.
LC_ALL=C awk '
BEGIN {
	# pre-calculate lookup table
	for (i = 1;i <= 47; ++i)
		ord[sprintf("%c", i)] = i
	for (i = 58;i <= 64; ++i)
		ord[sprintf("%c", i)] = i
	for (i = 91;i <= 96; ++i)
		ord[sprintf("%c", i)] = i
	for (i = 123;i < 256; ++i)
		ord[sprintf("%c", i)] = i
}
NR > 1 {
	printf "%%%02X", ord[ORS]
}
{
	l = $0
	while (match(l, /[^0-9A-Za-z.~_-]/)) {
		printf "%s%%%02X", substr(l, 1, RSTART-1), ord[substr(l, RSTART, 1)]
		l = substr(l, RSTART + 1)
	}
	printf "%s", l
}
END {
	printf "%s", ORS
}
' <<EOF
$*
EOF
