# Prints the ISO day of week for a given date in the Gregorian calendar
# 0 = Sunday, 1 = Monday, ..., 6 = Saturday
#
# This implementation works for all dates since the introduction of the
# Gregorian calendar.
#
# Usage:
#  - day-of-week year month day
#  - day-of-week 1970 1 1
#  - day-of-week 2020 2 29
#  - day-of-week 2070 10 20

: "${1:?missing year}" "${2:?missing month}" "${3:?missing day}"
# remove leading zeroes from arguments to prevent them from being interpreted
# as octal. The year is ignored because the Gregorian calendar was only
# introduced in the 16th century.
set -- "${1}" "${2#0}" "${3#0}"

# RFC 3339, Appendix B

set -- $(($2 >= 3 ? $1 : ($1 - 1))) $(($2 >= 3 ? ($2 - 2) : ($2 + 10))) $(($3))
echo $((
	(
		(26 * $2 - 2) / 10
		+ $3
		+ ($1 % 100)
		+ (($1 % 100) / 4)
		+ ($1 / 400)
		+ (5 * ($1 / 100))
	) % 7
))
