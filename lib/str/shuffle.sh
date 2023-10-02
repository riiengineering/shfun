awk -v seed="${SHUFFLE_SEED:-$(date +%s)}" 'BEGIN {
	srand(seed)
}
{ x[NR] = $0 }
END {
	for (i = 1; i <= NR; ++i) {
		r = i + int(rand() * (NR-i+1))
		print x[r]
		x[r] = x[i]
	}
}' "$@"
