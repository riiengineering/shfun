{
	k = 0
	m = substr($0, 1, 10)
	for (i = 8; i >= 0; --i) {
		c = substr(m, 10-i, 1)
		k += ((c~/[rwxst]/)*2^i)
		if ((i % 3) == 0) {
			k += (tolower(c)~/[st]/)*2^(9+i/3)
		}
	}
	printf("%04o" ORS, k)
}
