# Compares numeric version numbers ($1 <=> $2).
# Exit statuses:
# - 0 if $1 == $2
# - 1-127 if $1 > $2
# - 128-255 if $1 < $2
#
# Usage:
#  - vercmp $ver_a $ver_b
#    res=$(($? - 128))
#    if test $((res)) -eq 0
#    then
#        # $ver_a = $ver_b
#    elif test $((res)) -gt 0
#    then
#        # $ver_a > $ver_b
#    else
#        # $ver_a < $ver_b
#    fi
#
#  - # Simple test if 3.1.4 >= 3.1
#    vercmp 3.1.4 3.1
#    if test $(($? - 128)) -ge 0
#    then
#        # ...
#    fi

{
	# NOTE: -k N,N is for GNU sort to not detect keys as spanning multiple
	#       fields, thus breaking leading zero detection.
	LC_ALL=C \
	sort -t . -u -k 1,1rn -k 2,2rn -k 3,3rn -k 4,4rn -k 5,5rn -k 6,6rn <<-EOF
	$1
	$2
	EOF
} \
| {
	read -r _low
	read -r _upp

	case ${_upp}
	in
		('')
			# versions are equal if sort only prints one line
			exit 0 ;;
		("$2")
			exit 1 ;;
		("$1")
			exit 255 ;;  # -1 + 256
	esac
}
