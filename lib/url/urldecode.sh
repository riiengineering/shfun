# set the locale to C so that the input string can be indexed by byte
# in multi-byte locales, substr() will not index by byte but by character, instead.
LC_ALL=C awk '
BEGIN {
	xdigit["0"] =  0; xdigit["1"] =  1; xdigit["2"] =  2; xdigit["3"] =  3
	xdigit["4"] =  4; xdigit["5"] =  5; xdigit["6"] =  6; xdigit["7"] =  7
	xdigit["8"] =  8; xdigit["9"] =  9; xdigit["A"] = 10; xdigit["B"] = 11
	xdigit["C"] = 12; xdigit["D"] = 13; xdigit["E"] = 14; xdigit["F"] = 15
	                                    xdigit["a"] = 10; xdigit["b"] = 11
	xdigit["c"] = 12; xdigit["d"] = 13; xdigit["e"] = 14; xdigit["f"] = 15
}

function hex2dec(n,    _i, _r) {
	for (_i = 1; _i <= length(n); ++_i) {
		_r = (_r*16) + xdigit[substr(n, _i, 1)]
	}
	return _r
}

{
	while ((p = index($0, "%"))) {
		printf "%s%c", substr($0, 1, p-1), hex2dec(substr($0, p+1, 2))
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
