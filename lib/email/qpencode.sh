# set the locale to C so that the input string can be indexed by byte
# in multi-byte locales, substr() will not index by byte but by character, instead.
# TODO: compact mode
LC_ALL=C awk '
BEGIN {
	# pre-calculate lookup table
	for (i = 1;i <= 32; ++i)
		ord[sprintf("%c", i)] = i
	for (i = 127;i < 256; ++i)
		ord[sprintf("%c", i)] = i
}
{
	# encode all =, first, for simplicity
	gsub(/=/, "=3D")

	l = ""
	while ($0) {
		if (match($0, /[^[:print:]\n]| $/)) {
			l = l substr($0, 1, RSTART-1) sprintf("=%02X", ord[substr($0, RSTART, 1)])
			$0 = substr($0, RSTART+1)
		} else {
			l = l $0
			$0 = ""
		}

		while (length(l) > 76) {
			print substr(l, 1, 75) "="
			l = substr(l, 76)
		}
	}
	print l
}
' <<EOF
$*
EOF
